# Elm build
FROM node:11-alpine as elm-build

WORKDIR /app
COPY . .
RUN cd assets \
    && npm install \
    && npm run build-js \
    && npm run build-style

# Rust build
FROM rustlang/rust:nightly-slim as rust-build

RUN apt-get update
RUN apt-get install musl-tools -y
RUN rustup target add x86_64-unknown-linux-musl
WORKDIR /app
COPY . .
RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl
RUN useradd -u 10001 app

# App image
FROM scratch
COPY --from=rust-build /app/target/x86_64-unknown-linux-musl/release/app .
COPY --from=rust-build /app/templates ./templates
COPY --from=elm-build /app/dist ./dist
COPY --from=rust-build /etc/passwd /etc/passwd
USER app
EXPOSE 8000
CMD ["./app"]