#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
DEFCONFIG="${DEFCONFIG:=swift_arm64_defconfig}"

# Build and push base docker image
DOCKER_FILE=$SWIFT_BUILDROOT/.devcontainer/Dockerfile
docker build -t colemancda/buildroot-swift --file $DOCKER_FILE .devcontainer

# Create arch-specific Dockerfile
DOCKER_FILE_ARCH=$DOCKER_FILE-$DEFCONFIG
rm -rf $DOCKER_FILE_ARCH
echo "FROM colemancda/buildroot-swift" >> $DOCKER_FILE_ARCH
echo "ENV DEFCONFIG=${DEFCONFIG}" >> $DOCKER_FILE_ARCH
echo "ENV SWIFT_BUILDROOT=/workspaces/buildroot-swift" >> $DOCKER_FILE_ARCH
echo "ENV BUILDROOT_RELEASE=2024.02.9" >> $DOCKER_FILE_ARCH
echo "ENV BUILDROOT_DIR=/workspaces/buildroot" >> $DOCKER_FILE_ARCH
echo "COPY . /workspaces/buildroot-swift/" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/configure.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/configure.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/fetch-sources.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/fetch-sources.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-host-swift.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-host-swift.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-toolchain.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-toolchain.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-base.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-base.sh" >> $DOCKER_FILE_ARCH

# Build Docker image
docker build -t colemancda/buildroot-swift:$DEFCONFIG --file $DOCKER_FILE_ARCH .
docker push colemancda/buildroot-swift
docker push colemancda/buildroot-swift:$DEFCONFIG