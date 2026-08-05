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

- Align the published Tile catalog with the 106-instruction DavinciOO architecture set.
- Add `GMOV`, `TFMA`, `TRANDOM`, `TSORT32`, and `TMOV` to the published architecture documentation.
- Correct the canonical `TSEL`/`TSELS` encoding assignment and publish the accepted encodings for the newly added operations.
- Replace the previous `TSORT` identity with `TSORT32` and remove 18 operations that are not supported by this architecture version.
- Publish 26 active Block Intrinsics and isolate unsupported or historical Block/Header material from the public site.
- Consolidate the architecture reference, encoding workbook, and support status into the Complete documentation site.

## PTO ISA 0.57.1

Previous published baseline. See the repository history and the corresponding Git tag for the complete frozen contents of that release.

## Version-independent notes

- The public instruction set is the closed set listed by the Tile, Block, Scalar and System sections of this site.
- Internal review ledgers, archived drafts and unsupported Block/Header pages are not part of the published ISA.
