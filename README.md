# mongo-docker-builder
This repo provides a simple way to get the `mongo` and mongo tools binaries for debian/amd64 an debian/arm64.
It is meant to be built/used for Debian Stretch and Buster, use any other Debian versions at your own risk.

## How to build the binaries?
Simply do: `docker buildx build . -t mongo-docker-builder --platform linux/amd64 --build-arg OS_VERSION=stretch --load` (for instance)

## Where are they?
You can find the binaries under the `/finalBins/` folder of the container.

Several ways:
- Use `docker cp`
- Base your own Dockerfile on a Docker image built from the Dockerfile of this repo
- And so on

## Do I need anything to run these binaries?
Yes as they are not statically-compiled!
Please install `libcurl4-openssl-dev` before using them.