---
{
  "id": "ADR-0113",
  "title": "CUBE predicate carriers and TGPR2T superseding contract",
  "status": "accepted",
  "authors": ["PTO ISA maintainers"],
  "approvers": ["PTO ISA maintainers"],
  "created": "2026-08-31",
  "accepted": "2026-08-31",
  "rejected": null,
  "superseded": null,
  "baseline": "e811355419182144784af802ff4c86d6a7014c70",
  "target_releases": ["0.58.5"],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-B-IOR-BINDING-001",
    "PTO-B-DATR-FIELDS-001",
    "PTO-TCMP-CONTRACT-001",
    "PTO-TCMPS-CONTRACT-001",
    "PTO-TSEL-CONTRACT-001",
    "PTO-TSELS-CONTRACT-001",
    "PTO-TILE-MODEL-DEFINEDNESS-PREDICATE-CELL-001",
    "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-SCHEMA-001",
    "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001",
    "PTO-INST-BLOCK-B-DATR",
    "PTO-INST-BLOCK-B-IOR",
    "PTO-INST-TILE-TCMP",
    "PTO-INST-TILE-TCMPS",
    "PTO-INST-TILE-TGPR2T",
    "PTO-INST-TILE-TSEL",
    "PTO-INST-TILE-TSELS"
  ],
  "affected_units": [
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-MODEL-DISPATCH-COMPARISON-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY",
    "PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA",
    "PTO-TILE-MODEL-EXECUTION-COMPARISON",
    "PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS",
    "PTO-TILE-MODEL-STATE-ALLOCATION",
    "PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS",
    "PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT",
    "PTO-TILE-TCMP",
    "PTO-TILE-TCMPS",
    "PTO-TILE-TSEL",
    "PTO-TILE-TSELS",
    "PTO-TILE-TGPR2T"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/pull/172",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0113: CUBE predicate carriers and TGPR2T superseding contract

## Context

PR #172 exposed a contract conflict between the earlier CUBE predicate/TGPR2T
wording and the current review requirements. The earlier interpretation treated
architectural GPRs as 32-bit, allowed incomplete carrier inference, described
TGPR2T as a flat stream reshape, used the old M16 placement and reduced shapes,
and did not close PredicateCell status or whole-result definedness.

This record is based on the exact pre-change `origin/main` baseline
`e811355419182144784af802ff4c86d6a7014c70`. It complements the accepted
ADR-0112 type-role contract and supersedes only the earlier conflicting
interpretations for the affected owners. ADR-0111 remains an unrelated draft
record about the ASL functional-model boundary.

## Decision

- Architectural GPRs are 64-bit and the namespace is `GPR0..GPR23`. A TGPR2T
  source is one complete ordered 64-bit GPR; 32-bit and 16-bit fields are
  sub-planes, not architectural registers.
- `TCMP/TCMPS` and `TSEL/TSELS` use complete, mutually exclusive legacy, CUBE
  GPR, or CUBE PredicateCell schemas. CUBE predicate forms are limited to
  `CUBE_M16` and `CUBE_M32` and use the closed domain
  `FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, U8`.
  `CUBE_N8`, `FP64`, `S64`, `U64`, and mixed or inferred carriers are illegal.
- A GPR-producing compare writes at most one complete 64-bit destination GPR.
  For U8 forms, `B.DATR.Sat` selects the Low/High predicate half (`0`/`1`);
  it is not a reused `Canonicalize` meaning.
- TGPR2T consumes exactly two contiguous source-only `B.IOR` records with
  source arity `3+1`, followed by one destination-bearing `B.IOT`. Missing,
  non-contiguous, wrong-split, destination-bearing, or surplus records fault
  before allocation, snapshot, or publication.
- TGPR2T uses the 64-bit GPR sub-plane packing and row-wise transpose. Its
  destination descriptor is complete: CUBE_M32/U8 is `32x4`, CUBE_M16/U8 is
  `16x8`. `ByteOffset` is `RMode[16:15]`; M16 pair placement begins at
  `2*ByteOffset`.
- TGPR2T fills unselected columns with one numeric U8 `PadValue`. Zero and
  Max are legal whole-tile padding; Null is illegal. Payload, descriptor, and
  whole-tile definedness publish atomically, and TGPR2T does not update GPR,
  compare, or numeric status.
- PredicateCell valid payload bytes are exactly `0x00` or `0x01`. PredicateCell
  may use per-element Null/undefined padding under its own definedness scheme;
  compare `element_flags` and status are retained and atomically published.
- TGPR2T produces an ordinary numeric U8 CUBE Tile. It does not carry a
  PredicateCell tag and is not an implicit TSEL/TSELS mask. Any conversion to
  a predicate carrier requires a later explicit architecture decision.

## Supersession and implementation boundary

The decision supersedes only the conflicting earlier CUBE predicate and TGPR2T
interpretations. It does not alter unrelated legacy packed-predicate behavior,
existing scalar/immediate source semantics, or the ADR-0111 functional-model
boundary. The affected authoritative owners now carry the executable TGPR2T
registration, complete dispatch schemas, PredicateCell state/evidence, decoded
AVS, and regenerated projections required by this decision.

## Owner and projection obligations

Current meaning remains in the affected ASL/NDF owners. The checked-in direct
projections are the generated instruction mirrors, catalogs, decoder/traceability
surfaces, ADR index, owner AVS, and commit-scoped evidence. The implementation
keeps the downstream boundary explicit: TGPR2T produces ordinary numeric U8 CUBE
output and does not silently become a PredicateCell or TSEL/TSELS mask.
