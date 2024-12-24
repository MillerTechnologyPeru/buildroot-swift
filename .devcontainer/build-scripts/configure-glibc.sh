#!/bin/bash
set -e

# Configurable
BUILDROOT_DIR="${BUILDROOT_DIR:=/workspaces/buildroot}"

# Build
cd $BUILDROOT_DIR
make swift_glibc_defconfig
