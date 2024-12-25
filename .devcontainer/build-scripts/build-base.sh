#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build
cd $WORKING_DIR

make $BUILDROOT_OPTIONS libbsd-build
make $BUILDROOT_OPTIONS libxml2-build
make $BUILDROOT_OPTIONS openssl-build
make $BUILDROOT_OPTIONS libcurl-build
