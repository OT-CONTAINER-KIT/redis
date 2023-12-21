<p align="left">
  <img src="./img/redis.png">
</p>

# Ot-Container-Kit (Redis)

I am a repo which have a production based Redis and Redis Exporter docker image codebase.

## Features

This image provides you below features:-
- [X] **Lightweight nature:-** Images are quite low in terms of size which will improve your deployment process time.
- [X] **Security Compliant:-** Images are security compliant i.e. It doesn't hold any vulnerable package.
- [X] **Best Practices:-** We have tried to follow the best practices for writing the Docker images.

## Pre-requisites

Here are the list of pre-requisites which is required for development and setup purpose.

- **Docker Engine**
- **Docker Compose**

## Image Compatibility

The following table shows the compatibility between the Operator Version, Redis Image, Sentinel Image, and Exporter Image:

| Operator Version | Redis Image | Sentinel Image | Exporter Image |
|------------------|-------------|----------------|----------------|
| v0.15.2          | v7.0.13     | v7.0.13        | v1.48.0        |
| v0.15.1          | v7.0.12     | v7.0.12        | v1.48.0        |
| v0.15.0          | v7.0.11     | v7.0.11        | v1.48.0        |
| v0.14.0          | v7.0.7      | v7.0.7         | v1.48.0        |
| v0.13.0          | v6.2.5      | nil            | v1.48.0        |

That's it

> Note : latest tag would be comptabile with latest operator version.

## Building Image

#### Redis Docker Image

```shell
make build-redis
```

#### Redis Exporter Docker Image

```shell
make build-redis-exporter
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
