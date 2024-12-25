#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build
mkdir -p $BR2_DL_DIR
cd $WORKING_DIR
echo "make $BUILDROOT_OPTIONS $BUILDROOT_DEFCONFIG"
make $BUILDROOT_OPTIONS $BUILDROOT_DEFCONFIG
