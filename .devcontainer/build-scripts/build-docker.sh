#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build and push base docker image
cd $SWIFT_BUILDROOT
docker build -t colemancda/buildroot-swift --file $DOCKER_FILE .devcontainer
docker push colemancda/buildroot-swift

# Copy Host Swift
HOST_SWIFT_SRCDIR_TMP=$SWIFT_BUILDROOT/host-swift-6.0.3
SWIFT_LLVM_BUILD_DIR_TMP=$HOST_SWIFT_SRCDIR_TMP/swift-source/build/buildbot_linux/llvm-linux-$(uname -m)

# Create host Swift folders
mkdir -p $HOST_SWIFT_SRCDIR_TMP
mkdir -p $HOST_SWIFT_SRCDIR_TMP/build
mkdir -p $HOST_SWIFT_SRCDIR_TMP/build/llvm
mkdir -p $HOST_SWIFT_SRCDIR_TMP/swift-source
mkdir -p $HOST_SWIFT_SRCDIR_TMP/swift-source/build
mkdir -p $HOST_SWIFT_SRCDIR_TMP/swift-source/build/buildbot_linux
mkdir -p $HOST_SWIFT_SRCDIR_TMP/swift-source/build/buildbot_linux/llvm-linux-$(uname -m)

# Copy host Swift files
echo "Copy Swift binaries"
cp -rf $HOST_SWIFT_SRCDIR/build/usr $HOST_SWIFT_SRCDIR_TMP/build/
echo "Copy LLVM binaries"
cp -rf $SWIFT_LLVM_BUILD_DIR/* $SWIFT_LLVM_BUILD_DIR_TMP/

# Clone Swift StdLib dependencies
mkdir -p $HOST_SWIFT_SRCDIR_TMP/swift-source
cd $HOST_SWIFT_SRCDIR_TMP/swift-source
if [ ! -d "$HOST_SWIFT_SRCDIR_TMP/swift-source/swift-corelibs-libdispatch" ]; then
    git clone https://github.com/swiftlang/swift-corelibs-libdispatch.git
    cd swift-corelibs-libdispatch
    git checkout $SWIFT_VERSION
    cd ../
fi
if [ ! -d "$HOST_SWIFT_SRCDIR_TMP/swift-source/swift-experimental-string-processing" ]; then
    git clone https://github.com/swiftlang/swift-experimental-string-processing.git
    cd swift-experimental-string-processing
    git checkout $SWIFT_VERSION
    cd ../
fi

# Create Dockerfile
cd $SWIFT_BUILDROOT
DOCKER_FILE_ARCH=$SWIFT_BUILDROOT/.devcontainer/Dockerfile-$BUILDROOT_DEFCONFIG
rm -rf $DOCKER_FILE_ARCH
echo "FROM colemancda/buildroot-swift" >> $DOCKER_FILE_ARCH
echo "ENV SWIFT_TARGET_ARCH=${SWIFT_TARGET_ARCH}" >> $DOCKER_FILE_ARCH
echo "ENV SWIFT_BUILDROOT=/workspaces/buildroot-swift" >> $DOCKER_FILE_ARCH
echo "ENV BUILDROOT_DIR=/workspaces/buildroot" >> $DOCKER_FILE_ARCH
echo "COPY . /workspaces/buildroot-swift/" >> $DOCKER_FILE_ARCH
echo "RUN mv /workspaces/buildroot-swift/host-swift-6.0.3 ./output/${SWIFT_TARGET_ARCH}/build/" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/configure.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/configure.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/fetch-sources.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/fetch-sources.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-host-tools.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-host-tools.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-host-swift.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-host-swift.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-toolchain.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-toolchain.sh" >> $DOCKER_FILE_ARCH
echo "COPY .devcontainer/build-scripts/build-base.sh /tmp/build-scripts/" >> $DOCKER_FILE_ARCH
echo "RUN /bin/bash /tmp/build-scripts/build-base.sh" >> $DOCKER_FILE_ARCH

# Build Docker image
docker build -t colemancda/buildroot-swift:$BUILDROOT_DEFCONFIG --file $DOCKER_FILE_ARCH .
docker push colemancda/buildroot-swift:$BUILDROOT_DEFCONFIG

# Cleanup
rm -rf $HOST_SWIFT_SRCDIR_TMP