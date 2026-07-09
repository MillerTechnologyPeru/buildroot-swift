#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Shrink the CI image so GitHub-hosted runners can pull it without
# running out of disk.

# Remove downloaded source tarballs; the CI build re-downloads the few it needs
rm -rf $BUILDROOT_DIR/dl $WORKING_DIR/dl

# NOTE: package build directories under $BUILDROOT_OUTPUT/build are NOT
# stripped here. Buildroot uses a package's build directory, not just its
# stamp files, to decide whether later steps (e.g. a host package's
# install step, run separately from its build step) still need to run.
# Deleting sources while keeping stamps caused false "already done"
# detection and broke host-fakeroot's install step in CI.
