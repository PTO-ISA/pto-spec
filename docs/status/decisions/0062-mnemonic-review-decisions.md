---
{
  "id": "ADR-0062",
  "title": "PTO mnemonic review decisions",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-11",
  "accepted": "2026-08-11",
  "rejected": null,
  "superseded": "2026-08-21",
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1",
    "0.58.2"
  ],
  "affected_ndf": [],
  "affected_units": [],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [
    "ADR-0075",
    "ADR-0076",
    "ADR-0077",
    "ADR-0078",
    "ADR-0079",
    "ADR-0080",
    "ADR-0081",
    "ADR-0082",
    "ADR-0083",
    "ADR-0084",
    "ADR-0085"
  ],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0062: PTO mnemonic review decisions (historical summary)

## Historical audit provenance

The mnemonic audit was accepted on 2026-08-11. It reviewed all 634 active PTO
mnemonics and all 40 occupied extension reservations. Coverage counted a
mnemonic when either this audit or an earlier accepted architecture ADR owned
its family decision; mnemonic-local duplicate decisions were not required.

At the audit freeze, coverage was therefore 634/634 active mnemonics and 40/40
occupied reservations. The reviewed conditional-branch change moved eight
families from the active inventory to the reservation inventory without
changing total reviewed coverage. Audit coverage remained distinct from later
formal implementation closure measured by per-ASL `PTO-REVIEW` records and the
compatibility audit tooling.

The contemporaneous binary projection contained 466 Scalar forms and 74 active
Block forms, for 540 active encoded forms, plus 40 occupied extension
reservations. These totals are historical evidence, not the current release
inventory; generated catalogs and release evidence remain authoritative.

## Successor decision records

The 183 operative mnemonic decisions and their legacy identities are now owned
by the following decision-scoped records:

- [ADR 0075](0075-block-attributes-and-lifecycle.md) — Block attributes and lifecycle
- [ADR 0076](0076-block-scalar-and-tile-bindings.md) — Block scalar and tile bindings
- [ADR 0077](0077-block-start-and-extension-reservations.md) — Block start and extension reservations
- [ADR 0078](0078-tlsu-and-global-memory-operations.md) — TLSU and global-memory operations
- [ADR 0079](0079-cube-and-matrix-operations.md) — CUBE and matrix operations
- [ADR 0080](0080-tile-elementwise-and-irregular-operations.md) — Tile elementwise and irregular operations
- [ADR 0081](0081-tile-scalar-and-immediate-operations.md) — Tile scalar and immediate operations
- [ADR 0082](0082-tile-reduction-expansion-and-generation.md) — Tile reduction, expansion, and generation
- [ADR 0083](0083-tile-conversion-layout-and-partial-operations.md) — Tile conversion, layout, and partial operations
- [ADR 0084](0084-scalar-system-and-queue-operations.md) — Scalar, system, and queue operations
- [ADR 0085](0085-numeric-postprocess-and-format-operations.md) — Numeric post-process and format operations

This record is historical provenance only and owns no current semantic impact
or legacy identifier.
