#!/bin/bash
set -e

# Paths
BUILDROOT_DIR="${BUILDROOT_DIR:=/workspaces/buildroot}"

# Build
cd $BUILDROOT_DIR
make host-swift-build
