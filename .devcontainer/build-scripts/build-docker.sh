#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build and push base docker image
cd $SWIFT_BUILDROOT
docker build -t colemancda/buildroot-swift --file $DOCKER_FILE .devcontainer
docker push colemancda/buildroot-swift

# Create Dockerfile
cd $SWIFT_BUILDROOT
DOCKER_FILE_ARCH=$SWIFT_BUILDROOT/.devcontainer/Dockerfile-$BUILDROOT_DEFCONFIG
rm -rf $DOCKER_FILE_ARCH
echo "FROM colemancda/buildroot-swift" >> $DOCKER_FILE_ARCH
echo "ENV SWIFT_TARGET_ARCH=${SWIFT_TARGET_ARCH}" >> $DOCKER_FILE_ARCH
echo "ENV SWIFT_BUILDROOT=/workspaces/buildroot-swift" >> $DOCKER_FILE_ARCH
echo "ENV BUILDROOT_DIR=/workspaces/buildroot" >> $DOCKER_FILE_ARCH
echo "COPY . /workspaces/buildroot-swift/" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/configure.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/configure.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/fetch-sources.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/fetch-sources.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-host-tools.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-host-tools.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/library-scripts/install-swift.sh /tmp/library-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/library-scripts/install-swift.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-toolchain.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-toolchain.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-base.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-base.sh" >> $DOCKER_FILE_ARCH

# Build Docker image
docker build -t colemancda/buildroot-swift:$BUILDROOT_DEFCONFIG --file $DOCKER_FILE_ARCH .
docker push colemancda/buildroot-swift:$BUILDROOT_DEFCONFIG
