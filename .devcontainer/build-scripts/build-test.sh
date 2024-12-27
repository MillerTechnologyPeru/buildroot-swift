#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build
cd $WORKING_DIR
echo "BR2_PACKAGE_SWIFT_HELLO=y" >> $BUILDROOT_CONFIG
make $BUILDROOT_OPTIONS swift-hello-build
make $BUILDROOT_OPTIONS
file $BUILDROOT_TARGET/usr/bin/swift-hello