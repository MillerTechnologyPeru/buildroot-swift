#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Build
cd $WORKING_DIR

make $BUILDROOT_OPTIONS host-cmake-build
make $BUILDROOT_OPTIONS host-ninja-build
make $BUILDROOT_OPTIONS host-util-linux-build
make $BUILDROOT_OPTIONS host-libtool-build
make $BUILDROOT_OPTIONS host-autoconf-build
make $BUILDROOT_OPTIONS host-automake-build
make $BUILDROOT_OPTIONS host-libzlib-build
make $BUILDROOT_OPTIONS host-zlib-build
make $BUILDROOT_OPTIONS host-attr-build
make $BUILDROOT_OPTIONS host-acl-build
make $BUILDROOT_OPTIONS host-fakeroot-build
make $BUILDROOT_OPTIONS host-dosfstools-build
