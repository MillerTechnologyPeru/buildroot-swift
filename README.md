# buildroot-swift
Buildroot external to support the Swift programming language

## Supported architectures

Built and smoke-tested by the `Buildroot` workflow. Every architecture is
built from source, toolchain included, which is hours of compute per
architecture: the workflow runs on a self-hosted runner and is started by
hand rather than on every push.

| defconfig | Architecture | libc |
| --- | --- | --- |
| `swift_arm64_defconfig` | AArch64 | glibc |
| `swift_armv7_defconfig` | Armv7-A, hard float | glibc |
| `swift_armv6_defconfig` | Armv6, hard float | glibc |
| `swift_armv5_defconfig` | Armv5TE | glibc |
| `swift_x86_64_defconfig` | x86-64 | glibc |
| `swift_x86_64_musl_defconfig` | x86-64 | musl |
| `swift_i386_defconfig` | i686 | glibc |
| `swift_ppc64le_defconfig` | PowerPC 64-bit, little endian | glibc |

### Experimental

These build the Swift stdlib only, from the `Buildroot experimental` workflow,
which is run by hand on the same self-hosted runner.

| defconfig | Architecture | libc |
| --- | --- | --- |
| `swift_ppc_defconfig` | PowerPC 32-bit | glibc |
| `swift_mipsel_defconfig` | MIPS 32r6, little endian | glibc |
| `swift_mips_defconfig` | MIPS 32r6, big endian | glibc |
| `swift_mips64el_defconfig` | MIPS 64r6 N64, little endian | glibc |
| `swift_mips64_defconfig` | MIPS 64r6 N64, big endian | glibc |
| `swift_riscv64_defconfig` | RISC-V 64-bit | glibc |

MIPS, 32-bit PowerPC and RISC-V need the Swift calling convention in clang,
which no Swift release carries yet. The patches are in
`package/swift/swift-source-patches/llvm-project/`, and they only take effect
in a toolchain built from source, which is why CI no longer runs in the
arch-tagged Docker images: those bake in a prebuilt toolchain via
`install-swift.sh`, which unpacks a swift.org build and symlinks
`SWIFT_LLVM_DIR` at the system LLVM. `host-swift` then finds its output
already there and skips its own build, so the patches never reach the clang
that compiles the target stdlib and `swiftcall` is silently ignored rather
than rejected.

RISC-V 64 looks at first like it needs no such patch - `RISCVTargetCodeGenInfo`
does register a `SwiftABIInfo` upstream - but that is only the CodeGen half.
`RISCVTargetInfo::checkCallingConvention` rejects `CC_Swift`, so sema drops the
attribute before CodeGen ever sees it and the runtime headers fail on every
`SWIFT_CONTEXT` parameter, and `LowerFormalArguments` has no case for
`CallingConv::Swift`. Both are patched here.

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
