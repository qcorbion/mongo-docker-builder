# mongo-docker-builder
This repo provides a simple way to get the `mongo` and mongo tools binaries for debian/amd64 an debian/arm64.

Simply do: `docker buildx build . -t mongo-docker-builder --platform linux/amd64 --build-arg OS_VERSION=stretch --load` (for instance)
