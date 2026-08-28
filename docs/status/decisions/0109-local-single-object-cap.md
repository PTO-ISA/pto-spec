---
{
  "id": "ADR-0109",
  "title": "Local single-object cap versus aggregate Local pool",
  "status": "accepted",
  "authors": ["PTO ISA maintainers"],
  "approvers": ["PTO ISA maintainers"],
  "created": "2026-08-27",
  "accepted": "2026-08-27",
  "rejected": null,
  "superseded": null,
  "baseline": "7dc8b7e5b121d2b2499a2273bebff29e2cd86812",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-B-IOT-STREAM-001",
    "PTO-TILE-CAPACITY-PER-PE",
    "PTO-B-SUBVIEW-RANGE-001",
    "PTO-B-ASSEMBLE-RANGE-001",
    "PTO-INST-BLOCK-B-ASSEMBLE",
    "PTO-INST-BLOCK-B-SUBVIEW"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ARCHITECTURE",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-B-SUBVIEW",
    "PTO-BLOCK-B-ASSEMBLE",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-TILE-MODEL-STATE-DESCRIPTORS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/166",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0109: Local single-object cap versus aggregate Local pool

## Decision

ADR-0109 is a scoped clarification of ADR-0097. Each individual Local object
or `B.IOT` destination is limited to SizeCode `1..10`, encoding `128 B..64 KiB`.
Each PE retains an independent aggregate Local pool of `256 KiB`, so multiple
separate Local objects may jointly consume that pool. A single SizeCode-12
encoding is not a Local object form.

The common SizeCode byte mapping remains unchanged: codes `1..12` encode
`128 B..256 KiB`, and Shared `B.IOS` destinations continue to accept
SizeCode `1..12`.

For the already-defined range modifiers, raw `B.SUBVIEW` and `B.ASSEMBLE`
fields retain their decoded `1..12` domain. Their effective association is
role-dependent: Local groups reject source/parent sizes `11` and `12`, while
Shared groups retain the complete `1..12` domain. `B.ASSEMBLE` SizeCode zero
MIDDLE/LAST behavior and the Shared decisions recorded by ADR-0105,
ADR-0106, and ADR-0107 remain owned by those records and are not redefined
here.

## Boundary and evidence

Local `B.IOT` SizeCodes `11..12` are not assigned Local destination forms and
raise `Fault_IllegalInstruction` before Local binding or allocation effects.
Reserved SizeCodes `13..15` remain separately reserved. `B.SUBVIEW` and
`B.ASSEMBLE` retain raw assigned codes through 12; when raw code 11 or 12 is
associated with a Local group, it raises `Fault_TileLegality` before GPR reads
or carrier updates, while the same code remains legal for a Shared group.
Focused AVS proves a valid Local SizeCode-10 destination, both Local boundary
fault classes, multiple 64 KiB objects reaching one PE's 256 KiB aggregate,
Shared SizeCode-12 acceptance, and role-dependent range-modifier boundaries.

## Relationship to ADR-0097

This record does not supersede ADR-0097 and does not restate its unaffected
capacity-pool, encoding, cooperative group-M, or compatibility decisions.
ADR-0097 remains the historical record; its 0.58.4.1 amendment points to
ADR-0105, ADR-0106, and ADR-0107 for the Shared decisions it references.
