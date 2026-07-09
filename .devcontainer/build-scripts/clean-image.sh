#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Shrink the CI image so GitHub-hosted runners can pull it without
# running out of disk.

# Remove downloaded source tarballs; the CI build re-downloads the few it needs
rm -rf $BUILDROOT_DIR/dl $WORKING_DIR/dl

# Strip package build trees down to their buildroot stamp and metadata files.
# The toolchain and base dependencies are already installed into host/,
# staging/ and target/; buildroot only checks the stamps on rebuild.
# The pre-seeded host Swift toolchain must be kept.
cd $BUILDROOT_OUTPUT/build
for dir in */; do
    case "$dir" in
        host-swift-*) continue ;;
    esac
    find "$dir" -mindepth 1 \
        ! -name '.stamp*' \
        ! -name '.applied_patches_list' \
        ! -name '.files-list*' \
        ! -name '.br2_version' \
        -delete 2>/dev/null || true
done
