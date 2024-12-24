#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
DEFCONFIG="${DEFCONFIG:=swift_arm64_defconfig}"
BUILDROOT_DIR="${BUILDROOT_DIR:=/workspaces/buildroot}"

# Prepare environment
$SWIFT_BUILDROOT/.devcontainer/build-scripts/configure.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/fetch-sources.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-host-tools.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-host-swift.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-toolchain.sh
$SWIFT_BUILDROOT/.devcontainer/build-scripts/build-base.sh

# Build Swift
cd $BUILDROOT_DIR
make