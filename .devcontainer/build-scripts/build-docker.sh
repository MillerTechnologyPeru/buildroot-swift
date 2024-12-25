#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"

# Build and push base docker image
DOCKER_FILE=$SWIFT_BUILDROOT/.devcontainer/Dockerfile
cd $SWIFT_BUILDROOT
docker build -t colemancda/buildroot-swift --file $DOCKER_FILE .devcontainer
docker push colemancda/buildroot-swift