---
{
  "id": "ADR-0125",
  "title": "Bind indexed TLSU row-stride addressing",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "cbcd6abb2dc4d7f933d4db1124fadd11934d4c56",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
    "PTO-BSTART-MGATHER-MASK-SCHEMA-001",
    "PTO-BSTART-MGATHER-SCHEMA-001",
    "PTO-BSTART-MSCATTER-MASK-SCHEMA-001",
    "PTO-BSTART-MSCATTER-SCHEMA-001",
    "PTO-B-DATR-FIELDS-001",
    "PTO-INDEXED-TLSU-STRIDE-001",
    "PTO-INST-BLOCK-B-IOR",
    "PTO-INST-BLOCK-BSTART-MGATHER",
    "PTO-INST-BLOCK-BSTART-MGATHER-CAS",
    "PTO-INST-BLOCK-BSTART-MGATHER-MASK",
    "PTO-INST-BLOCK-BSTART-MSCATTER",
    "PTO-INST-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-MGATHER-BYTE-DISPLACEMENT-001",
    "PTO-MGATHER-CAS-ATOMIC-001",
    "PTO-MGATHER-CAS-PUBLICATION-001",
    "PTO-MGATHER-MASK-PREDICATE-001",
    "PTO-MGATHER-MASK-PUBLICATION-001",
    "PTO-MGATHER-MASK-TYPE-002",
    "PTO-MSCATTER-BYTE-DISPLACEMENT-001",
    "PTO-MSCATTER-DUPLICATE-ORDER-001",
    "PTO-MSCATTER-MASK-DUPLICATE-001",
    "PTO-MSCATTER-MASK-PREDICATE-001",
    "PTO-MSCATTER-MASK-TYPE-002"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-BSTART-MGATHER",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-MASK",
    "PTO-BLOCK-BSTART-MSCATTER",
    "PTO-BLOCK-BSTART-MSCATTER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA",
    "PTO-TILE-MODEL-MEMORY-ADDRESSING",
    "PTO-TILE-MODEL-MEMORY-ATOMICS",
    "PTO-TILE-MODEL-MEMORY-GATHER-SCATTER",
    "PTO-TILE-MSCATTER",
    "PTO-TILE-MSCATTER-MASK"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/209",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0125: Bind indexed TLSU row-stride addressing

## Context

The compiler supplies two B.IOR sources for indexed TLSU blocks: the GM base
address and the GM row stride. PTO modeled the second source as required zero
and interpreted IndexTile elements as byte displacements. Complete compiler
MGATHER and MSCATTER blocks therefore rejected before execution.

## Decision

MGATHER, MSCATTER, MGATHER.MASK, MSCATTER.MASK, and MGATHER.CAS use this common
address rule:

- B.IOR RegSrc0 supplies the GM base address;
- B.IOR RegSrc1 supplies the nonzero GM row stride in elements;
- RegSrc2 and RegDst remain zero;
- each signed or unsigned IndexTile element is a logical linear element index;
- `ValidCol` is the logical row width used to split index `k` into
  `q=floor(k/ValidCol)` and `r=k-q*ValidCol`, where `0 <= r < ValidCol`;
- the GM element offset is `q*stride+r`, and the byte address is the base plus
  that element offset times the transfer DataType size;
- stride must be at least ValidCol and rejects before address probes, memory
  events, allocation, destination publication, or stores.

Signed negative indices use the same floor-division rule and may address rows
before the base. Disabled mask lanes do not evaluate their index or address.

## Compatibility

- Opcode, Tile binding order, dimensions, types, masks, preflight, ordering,
  fault precision, duplicate-address policy, and publication do not change.
- B.IOR RegSrc1 changes from required zero to required row stride.
- IndexTile elements change from byte displacements to logical element
  indices. A contiguous row-major tensor uses stride equal to ValidCol.

## Verification obligations

- Direct and decoded tests cover contiguous and padded row strides, signed
  negative indices, every transfer width, and stride rejection.
- MASK variants prove disabled invalid indices remain unobserved.
- CAS and scatter preserve complete preflight and atomic publication rules.
- The six compiler-generated MGATHER/MSCATTER ELF cases match independent
  result goldens.

## Decision state

The architecture owner confirmed the required stride operand on 2026-09-01.
