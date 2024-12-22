#!/bin/bash
set -e

# Paths
BUILDROOT_DIR="${BUILDROOT_DIR:=/workspaces/buildroot}"

# Build
cd $BUILDROOT_DIR
make host-swift-build
make host-cmake-build
make host-util-linux-build
make host-libtool-build
make host-autoconf-build
make host-automake-build
make host-libzlib-build
make host-zlib-build
make host-attr-build
make host-acl-build
make host-fakeroot-build
make host-dosfstools-build
