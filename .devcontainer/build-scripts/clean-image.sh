#!/bin/bash
set -e

# Configurable
SWIFT_BUILDROOT="${SWIFT_BUILDROOT:=$(pwd)}"
source $SWIFT_BUILDROOT/.devcontainer/build-scripts/swift-define

# Shrink the CI image so GitHub-hosted runners can pull it without
# running out of disk.
#
# NOTE: neither dl/ nor package build directories under
# $BUILDROOT_OUTPUT/build are stripped here. Buildroot's download stamp
# ($(pkg)_DIR/.stamp_downloaded, see pkg-generic.mk) lives inside the
# package's build directory, not in dl/, and buildroot trusts that stamp
# without checking dl/ still has the tarball. Deleting dl/ while a
# package's .stamp_downloaded survives (e.g. busybox, always selected)
# makes buildroot skip straight to extracting a tarball that no longer
# exists. The same class of bug broke host-fakeroot's install step when
# build directories were stripped instead (see git history) — buildroot
# uses directory contents, not just stamp files, to decide whether a
# step still needs to run, and there is no known-safe subset to remove.
