#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build
cd $WORKING_DIR
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-host-tools.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-host-swift.sh

# Create symlinks for multiarch
declare -a arr=("arm64" "armv7" "armv6" "armv5" "x86_64" "i386" "ppc64le" "ppc" "riscv64" "mips64" "mips")
for i in "${arr[@]}"
do
    if [[ "$i" != "$SWIFT_TARGET_ARCH" ]]; then
        echo "Generating host tools symlink for $i"
        BUILDROOT_OUTPUT_ARCH=$WORKING_DIR/output/$i
        mkdir -p $BUILDROOT_OUTPUT_ARCH
        mkdir -p $BUILDROOT_OUTPUT_ARCH/build/
        cd $BUILDROOT_OUTPUT_ARCH
        ln -s ../$SWIFT_TARGET_ARCH/host $BUILDROOT_OUTPUT_ARCH/host
        ln -s ../$SWIFT_TARGET_ARCH/build/host-* $BUILDROOT_OUTPUT_ARCH/build/
    fi
done

