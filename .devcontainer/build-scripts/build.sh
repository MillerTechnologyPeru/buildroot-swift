#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Prepare environment
$SWIFT_BUILDROOT/.devcontainer/build-scripts/configure.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/fetch-sources.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-host-tools.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-toolchain.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-base.sh

# Build Swift
cd $WORKING_DIR
make $BUILDROOT_OPTIONS