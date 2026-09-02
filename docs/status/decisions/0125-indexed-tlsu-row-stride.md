---
{
  "id": "ADR-0125",
  "title": "Bind indexed TLSU Row and Elem addressing",
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
    "PTO-B-IOT-STREAM-001",
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
    "PTO-MSCATTER-MASK-TYPE-002",
    "PTO-REQ-TILE-001"
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
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-DECODE",
    "PTO-BLOCK-MODEL-LIFECYCLE-RESET",
    "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-ARCH-PROFILE-RESET",
    "PTO-TILE-MGATHER",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-MASK",
    "PTO-TILE-MODEL-STATE-ALLOCATION",
    "PTO-TILE-MODEL-STATE-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS",
    "PTO-TILE-MODEL-STATE-TYPES",
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

# ADR 0125: Bind indexed TLSU Row and Elem addressing

## Context

Indexed gather and scatter require both one-index-per-row and
one-index-per-element addressing. Row addressing also requires an independent
GM stride, while element addressing does not. The architecture therefore needs
an explicit mode rather than inferring semantics from an IndexTile shape.

## Decision

MGATHER, MSCATTER, MGATHER.MASK, and MSCATTER.MASK use B.DATR CMode as an
operation-specific coalescing selector:

- CMode=0 selects Row; CMode=1 selects Elem; CMode 2..5 is inapplicable;
- RegSrc0 always supplies the GM base address;
- Row uses a canonical row-major `1 x ValidRow` S32/U32 IndexTile and consumes
  RegSrc1 as a nonzero GM row stride in elements;
- Row address `(r,c)` is
  `base + (IndexTile[0,r] * stride + c) * sizeof(DataType)`;
- Elem uses a row-major S32/U32 IndexTile matching the data valid shape and
  requires RegSrc1 to encode zero;
- Elem address `(r,c)` is
  `base + IndexTile[r,c] * sizeof(DataType)`;
- RegSrc2 and RegDst remain zero in both modes.

B.IOT source codes remain relative T/U/M/N selectors. Each source is resolved
against the newest-first published hand order before the indexed operation;
each successfully published destination becomes #1 of its selected hand and
older persistent generations shift toward #16.

Signed negative indices may address before the base. Disabled mask lanes do
not evaluate their selected index or address.

MGATHER.CAS is not part of that row-index ABI. It retains the existing
per-element byte-displacement rule and requires B.IOR RegSrc1, RegSrc2, and
RegDst to encode zero.

## Compatibility

- Opcode, Tile binding order, dimensions, types, masks, preflight, ordering,
  fault precision, duplicate-address policy, and publication do not change.
- The four non-CAS indexed TLSU operations explicitly support both programming
  model modes without changing their opcodes.
- Row consumes RegSrc1 stride; Elem requires RegSrc1 zero.
- IndexTile is restricted to the S32/U32 PTO common subset.
- MGATHER.CAS remains byte-displacement based and does not consume stride.
- Relative Tile naming is restored in the executable ASL model without
  changing source persistence, L semantics, or encoded B.IOT fields.

## Verification obligations

- Direct and decoded tests cover Row and Elem, contiguous and padded row
  strides, signed negative indices, S32/U32 legality, mode rejection, and the
  Elem zero-stride-selector rule.
- MASK variants prove disabled invalid indices remain unobserved.
- CAS preserves its byte-displacement ABI and atomic publication rules;
  scatter preserves complete preflight.
- A TLOAD-index, MGATHER-destination, TSTORE chain proves that the new T
  generation becomes T#1 while the prior IndexTile remains available as T#2.

## Decision state

The architecture owner confirmed explicit Row/Elem CMode semantics on
2026-09-02.
