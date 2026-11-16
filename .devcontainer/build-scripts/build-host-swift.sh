#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build
cd $WORKING_DIR
make $BUILDROOT_OPTIONS host-swift-build

# Create symlinks for multiarch
declare -a arr=("arm64" "armv7" "armv6" "armv5" "x86_64" "x86_64_musl" "i386" "ppc64le" "ppc" "riscv64" "mipsel" "mips64el" "mips" "mips64")
for i in "${arr[@]}"
do
    if [[ "$i" != "$SWIFT_TARGET_ARCH" ]]; then
        BUILDROOT_OUTPUT_ARCH=$WORKING_DIR/output/$i
        mkdir -p $BUILDROOT_OUTPUT_ARCH
        mkdir -p $BUILDROOT_OUTPUT_ARCH/build/
        cd $BUILDROOT_OUTPUT_ARCH/build
        if [ ! -d "$BUILDROOT_OUTPUT_ARCH/build/host-swift-$SWIFT_RELEASE" ]; then
            echo "Generating host tools symlink for $i"
            ln -s ../../$SWIFT_TARGET_ARCH/build/host-swift-$SWIFT_RELEASE ./host-swift-$SWIFT_RELEASE
            rm $BUILDROOT_OUTPUT_ARCH/build/host-swift-$SWIFT_RELEASE/.stamp_host_installed
        fi
    fi
done