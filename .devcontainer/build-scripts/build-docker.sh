#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
DEFCONFIG="${DEFCONFIG:=imx6slevk_swift_defconfig}"

# Create Dockerfile
DOCKER_FILE_ARCH=$SWIFT_BUILDROOT/.devcontainer/Dockerfile-$DEFCONFIG
rm -rf $DOCKER_FILE_ARCH
echo "FROM colemancda/buildroot-swift" >> $DOCKER_FILE_ARCH
echo "ENV DEFCONFIG=${DEFCONFIG}" >> $DOCKER_FILE_ARCH
echo "ENV SWIFT_NATIVE_TOOLS=/workspaces/swift/usr/bin" >> $DOCKER_FILE_ARCH
echo "ENV SWIFT_LLVM_DIR=/workspaces/llvm" >> $DOCKER_FILE_ARCH
echo "ENV SWIFT_BUILDROOT=/workspaces/buildroot-swift" >> $DOCKER_FILE_ARCH
echo "ENV BUILDROOT_RELEASE=2024.02.9" >> $DOCKER_FILE_ARCH
echo "ENV BUILDROOT_DIR=/workspaces/buildroot" >> $DOCKER_FILE_ARCH
echo "COPY . /workspaces/buildroot-swift/" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/configure.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/configure.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/fetch-sources.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/fetch-sources.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-base.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-base.sh" >> $DOCKER_FILE_ARCH

# Build Docker image
docker build -t colemancda/buildroot-swift:$DEFCONFIG --file $DOCKER_FILE_ARCH .
docker push colemancda/buildroot-swift:$DEFCONFIG