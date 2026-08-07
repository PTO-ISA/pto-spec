---
{
  "schema_version": 1,
  "id": "status.version-history",
  "kind": "coverage",
  "title": "Version History",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Support Status",
  "xlsx": { "order": 1 }
}
---
# Version History

## PTO ISA 0.58.0

Current documentation version.

Changes from PTO ISA 0.57.1:

- Reissue 0.58.0 in place with new content hashes; objects and toolchains built
  against the superseded 0.58 tree are incompatible and must be rebuilt.
- Define `B.IOT.TSize` and `B.IOS.TSize` as 128 B–8 KiB per selected PE, with
  Core allocation equal to `popcount(PE_MASK) * per_PE_size`.
- Replace the retired 16-bit `C.B.IOS` with 32-bit `B.IOS`, carrying absolute
  `S0..S255`, source/destination role, per-PE size, and PE mask in the Bundle
  Input & Output encoding group.
- Align the published Tile catalog with the 109-operation DavinciOO architecture set.
- Add `GMOV` and `TFMA`, retain `THISTOGRAM`, and publish Shared `TMOV` variants.
- Correct the canonical `TSEL`/`TSELS` encoding assignment and publish the accepted encodings for the newly added operations.
- Replace the fixed-width `TSORT32` identity with `TSORT` plus explicit `sort_width`, reserve `TRANDOM`, and remove operations that are not supported by this architecture version.
- Publish Scalar ISA, Block ISA, and Tile ISA as the three instruction categories.
- Publish 26 active Block ISA pages and isolate unsupported or historical Block/Header material from the public site.
- Consolidate the architecture reference, encoding workbook, and support status into the Complete documentation site.

## PTO ISA 0.57.1

Previous published baseline. See the repository history and the corresponding Git tag for the complete frozen contents of that release.

## Version-independent notes

- The public instruction set is the closed set listed by the Scalar ISA, Block ISA, and Tile ISA sections of this site.
- Internal review ledgers, archived drafts and unsupported Block/Header pages are not part of the published ISA.
