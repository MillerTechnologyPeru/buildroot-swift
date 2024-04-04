#!/bin/bash
set -e

BUILDROOT_RELEASE="${BUILDROOT_RELEASE:=2024.02.1}"
BUILDROOT_DIR="${BUILDROOT_DIR:=/workspaces/buildroot}"

cd /tmp/
wget "https://buildroot.org/downloads/buildroot-$BUILDROOT_RELEASE.tar.gz"
tar -xf "buildroot-$BUILDROOT_RELEASE.tar.gz"
mv "buildroot-$BUILDROOT_RELEASE" $BUILDROOT_DIR
rm -rf "buildroot-$BUILDROOT_RELEASE.tar.gz"
