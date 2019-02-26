#---------------------Elm build
FROM node:11-alpine as elm-build

WORKDIR /app

## For node dependency caching we build a default project with the required dependencies
COPY assets/package.json assets/package-lock.json assets/
WORKDIR /app/assets
RUN npm install

## Build the actuals project
COPY assets ./
RUN npm run build-js
RUN npm run build-style

#--------------------Rust build
FROM rustlang/rust:nightly-slim as rust-build

RUN apt-get update
RUN apt-get install musl-tools -y
RUN rustup target add x86_64-unknown-linux-musl

## For rust dependency caching we build a default project with the required dependencies
RUN USER=root cargo new --bin app
WORKDIR /app
COPY ./Cargo.lock ./Cargo.lock
COPY ./Cargo.toml ./Cargo.toml
RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl
RUN rm src/*.rs

## Build the actual project
COPY ./src ./src
COPY templates templates
RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl
RUN useradd -u 10001 app

#--------------------App image
FROM scratch
COPY --from=rust-build /app/target/x86_64-unknown-linux-musl/release/app .
COPY --from=rust-build /app/templates ./templates
COPY --from=elm-build /app/dist ./dist
COPY --from=rust-build /etc/passwd /etc/passwd
USER app
EXPOSE 8000
CMD ["./app"]