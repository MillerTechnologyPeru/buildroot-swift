# buildroot-swift
Buildroot external to support the Swift programming language

## Swift sources

The Swift toolchain is built by swift's own `build-script`, which expects the
swift sources checked out next to every peer repository of the release — the
layout `update-checkout` produces. Buildroot fetches that whole set itself:

* `package/swift/swift.mk` builds `host-swift` from the release tarball and
  lists every peer repository in `HOST_SWIFT_EXTRA_DOWNLOADS`, so buildroot
  downloads and hash-checks them like any other source and `make source`
  fetches everything a build needs. Nothing is cloned while building, which is
  what makes an offline build possible.
* `package/swift/swift-sources.mk` holds the revisions, one line per
  repository. It is generated — do not edit it by hand.
* `package/swift/swift-source-patches/<repository>/` holds patches for the peer
  repositories. They are applied by buildroot's patch infrastructure, the same
  way `package/swift/*.patch` is applied to the swift sources themselves.

### Bumping the Swift version

1. Set `SWIFT_VERSION` in `package/swift/swift.mk` and update the release
   tarball hash in `package/swift/swift.hash`.
2. Regenerate the pins and their hashes:

   ```
   utils/gen-swift-source-pins.py <version>
   ```

   The script reads the pinned revisions from the `update-checkout` config of
   the release being built, which is the only place they are correct: those
   pins differ between releases, and taking them from `main` mixes in
   revisions the release was never tested against.
3. Bump the peer packages pinned to the same release (`libswiftdispatch`,
   `swift-foundation`, `xctest`) and the versions in
   `.devcontainer/build-scripts/swift-define`.
