#!/bin/bash
set -e

# Paths
BUILDROOT_DIR="${BUILDROOT_DIR:=/workspaces/buildroot}"

# Build
cd $BUILDROOT_DIR
make source
make libbsd-build
make libxml2-build
make openssl-build
make libcurl-build