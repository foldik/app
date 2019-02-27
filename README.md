# App

`rust`, `elm`, `docker`

## Prerequisite

- [Rust](https://www.rust-lang.org/)
- [Node](https://nodejs.org/en/)
- [Docker](https://www.docker.com/)

## Start with cargo

1. `rustup override set nightly`
1. `cargo run`
1. Go to the _assets_ folder and run `npm install && npm run build-js && npm run build-style`
1. Go to http://localhost:8000

## Start with docker

1. Build the docker image: `docker build -t app .`
1. Start the application: `docker run --rm -d -p 8000:8000 --name app app`
1. Go to http://localhost:8000
1. Check resource consumption: `docker stats --format "{{.Name}}: \n  ContainerId: {{.Container}}\n  Mem: {{.MemUsage}}\n  CPU: {{.CPUPerc}}"`