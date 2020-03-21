<p align="left">
  <img src="./img/redis.png">
</p>

# Ot-Container-Kit (Redis)

I am a repo which have a production based Redis and Redis Expoer docker image codebase.

## Features

This image provides you below features:-
- [X] Lightweight nature :- Images are quite low in terms of size which will improve your deployment process time.
- [X] Security Compliant :- Images are security compliant i.e. It doesn't hold any vulnerable package.
- [X] Best Practices :- We have tried to follow the best practices for writing the Docker images.

## Pre-requisites

Here are the list of pre-requisites which is required for development and setup purpose.

- **Docker Engine**
- **Docker Compose**

That's it

## Building Image

#### Redis Docker Image

```shell
make build-redis-image
```

#### Redis Exporter Docker Image

```shell
make build-redis-exporter-image
```

## Running Setup

#### For standalone server

```shell
make setup-standalone-server-compose
```

#### For cluster setup

```shell
make setup-cluster-compose
```
