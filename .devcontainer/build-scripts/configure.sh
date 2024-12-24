#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
DEFCONFIG="${DEFCONFIG:=swift_arm64_defconfig}"
BUILDROOT_DIR="${BUILDROOT_DIR:=/workspaces/buildroot}"

# Build
cd $BUILDROOT_DIR
make BR2_EXTERNAL=$SWIFT_BUILDROOT $DEFCONFIG
