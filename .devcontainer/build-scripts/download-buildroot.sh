#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

cd /tmp/
wget "https://buildroot.org/downloads/buildroot-$BUILDROOT_RELEASE.tar.gz"
tar -xf "buildroot-$BUILDROOT_RELEASE.tar.gz"
mv "buildroot-$BUILDROOT_RELEASE" $BUILDROOT_DIR
rm -rf "buildroot-$BUILDROOT_RELEASE.tar.gz"
