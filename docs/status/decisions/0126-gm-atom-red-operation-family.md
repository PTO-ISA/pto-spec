---
{
  "id": "ADR-0126",
  "title": "GM atom/red operation family",
  "status": "accepted",
  "authors": [
    "PTO ISA maintainers"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "d7806cc41f7200cb7b28e218f935c06767a3cda3",
  "target_releases": [
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-ATOM-RED-BODY-SCHEMA-001",
    "PTO-ATOM-RED-ENCODING-001",
    "PTO-ATOM-RED-FAULTS-001",
    "PTO-ATOM-RED-INC-DEC-SEMANTICS-001",
    "PTO-ATOM-RED-ORDERING-001",
    "PTO-ATOM-RED-POPC-SEMANTICS-001",
    "PTO-ATOM-RED-TYPE-LEGALITY-001",
    "PTO-B-ASSEMBLE-CONSUMER-READINESS-001",
    "PTO-B-ASSEMBLE-PRODUCER-EFFECT-ELIGIBILITY-001",
    "PTO-B-ASSEMBLE-SPECULATION-001",
    "PTO-BLOCK-MODEL-DISPATCH-TGPR2T-BOUNDARY-001",
    "PTO-BSTART-MGATHER-CAS-SCHEMA-001",
    "PTO-INST-BLOCK-BSTART-MGATHER-ADD",
    "PTO-INST-BLOCK-BSTART-MGATHER-AND",
    "PTO-INST-BLOCK-BSTART-MGATHER-CAS",
    "PTO-INST-BLOCK-BSTART-MGATHER-DEC",
    "PTO-INST-BLOCK-BSTART-MGATHER-EXCH",
    "PTO-INST-BLOCK-BSTART-MGATHER-INC",
    "PTO-INST-BLOCK-BSTART-MGATHER-MAX",
    "PTO-INST-BLOCK-BSTART-MGATHER-MIN",
    "PTO-INST-BLOCK-BSTART-MGATHER-OR",
    "PTO-INST-BLOCK-BSTART-MGATHER-XOR",
    "PTO-INST-BLOCK-BSTART-MSCATTER-ADD",
    "PTO-INST-BLOCK-BSTART-MSCATTER-AND",
    "PTO-INST-BLOCK-BSTART-MSCATTER-DEC",
    "PTO-INST-BLOCK-BSTART-MSCATTER-INC",
    "PTO-INST-BLOCK-BSTART-MSCATTER-MAX",
    "PTO-INST-BLOCK-BSTART-MSCATTER-MIN",
    "PTO-INST-BLOCK-BSTART-MSCATTER-OR",
    "PTO-INST-BLOCK-BSTART-MSCATTER-POPC",
    "PTO-INST-BLOCK-BSTART-MSCATTER-XOR",
    "PTO-INST-TILE-MGATHER-ADD",
    "PTO-INST-TILE-MGATHER-AND",
    "PTO-INST-TILE-MGATHER-CAS",
    "PTO-INST-TILE-MGATHER-DEC",
    "PTO-INST-TILE-MGATHER-EXCH",
    "PTO-INST-TILE-MGATHER-INC",
    "PTO-INST-TILE-MGATHER-MAX",
    "PTO-INST-TILE-MGATHER-MIN",
    "PTO-INST-TILE-MGATHER-OR",
    "PTO-INST-TILE-MGATHER-XOR",
    "PTO-INST-TILE-MSCATTER-ADD",
    "PTO-INST-TILE-MSCATTER-AND",
    "PTO-INST-TILE-MSCATTER-DEC",
    "PTO-INST-TILE-MSCATTER-INC",
    "PTO-INST-TILE-MSCATTER-MAX",
    "PTO-INST-TILE-MSCATTER-MIN",
    "PTO-INST-TILE-MSCATTER-OR",
    "PTO-INST-TILE-MSCATTER-POPC",
    "PTO-INST-TILE-MSCATTER-XOR",
    "PTO-MGATHER-CAS-ATOMIC-001",
    "PTO-MGATHER-CAS-PUBLICATION-001"
  ],
  "affected_units": [
    "PTO-BLOCK-BSTART-MGATHER-ADD",
    "PTO-BLOCK-BSTART-MGATHER-AND",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-MGATHER-DEC",
    "PTO-BLOCK-BSTART-MGATHER-EXCH",
    "PTO-BLOCK-BSTART-MGATHER-INC",
    "PTO-BLOCK-BSTART-MGATHER-MAX",
    "PTO-BLOCK-BSTART-MGATHER-MIN",
    "PTO-BLOCK-BSTART-MGATHER-OR",
    "PTO-BLOCK-BSTART-MGATHER-XOR",
    "PTO-BLOCK-BSTART-MSCATTER-ADD",
    "PTO-BLOCK-BSTART-MSCATTER-AND",
    "PTO-BLOCK-BSTART-MSCATTER-DEC",
    "PTO-BLOCK-BSTART-MSCATTER-INC",
    "PTO-BLOCK-BSTART-MSCATTER-MAX",
    "PTO-BLOCK-BSTART-MSCATTER-MIN",
    "PTO-BLOCK-BSTART-MSCATTER-OR",
    "PTO-BLOCK-BSTART-MSCATTER-POPC",
    "PTO-BLOCK-BSTART-MSCATTER-XOR",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-TILE-MGATHER-ADD",
    "PTO-TILE-MGATHER-AND",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MGATHER-DEC",
    "PTO-TILE-MGATHER-EXCH",
    "PTO-TILE-MGATHER-INC",
    "PTO-TILE-MGATHER-MAX",
    "PTO-TILE-MGATHER-MIN",
    "PTO-TILE-MGATHER-OR",
    "PTO-TILE-MGATHER-XOR",
    "PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT",
    "PTO-TILE-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA",
    "PTO-TILE-MODEL-MEMORY-ATOMICS",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION",
    "PTO-TILE-MSCATTER-ADD",
    "PTO-TILE-MSCATTER-AND",
    "PTO-TILE-MSCATTER-DEC",
    "PTO-TILE-MSCATTER-INC",
    "PTO-TILE-MSCATTER-MAX",
    "PTO-TILE-MSCATTER-MIN",
    "PTO-TILE-MSCATTER-OR",
    "PTO-TILE-MSCATTER-POPC",
    "PTO-TILE-MSCATTER-XOR"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/208",
  "release_impact": "required",
  "legacy_ids": [],
  "release_boundary": true
}
---

# ADR 0126: GM atom/red operation family

## Decision

Add the GM-only indexed `MGATHER_*` and `MSCATTER_*` operation families on
TLSU Functions 8--27 using the fixed low carrier `0x11181`, mask `0x07ffffff`,
and no bit-25 expansion. Function 8 is the binary selector for `MGATHER_CAS`;
its accepted DataTypes are intentionally narrowed to `U16`, `U32`, and `U64`;
`U128` and non-U CAS types fault `Fault_TileLegality`.

MGATHER forms return their per-request old value in a destination tile. MSCATTER forms
have no destination; `MSCATTER_POPC` has no ValueTile and contributes one U32 update
per valid effective address. Every request is intrinsically atomic, duplicate
addresses serialize in implementation-defined order, and all addresses are
preflighted before effects. Floating ADD uses the frozen PTX-derived GM profile.


### Public naming clarification (2026-09-02)

The public indexed atomic operation names use the `MGATHER_*` and
`BSTART.MGATHER.*` spelling. The public reduction operation names use the
`MSCATTER_*` and `BSTART.MSCATTER.*` spelling. This is a naming-only revision:
TLSU Function 8--27 allocation, fixed carrier and mask, operand schemas,
DataType legality, fault ordering, duplicate-address ordering, preflight,
publication, restart, and numeric behavior are unchanged.

Internal semantic identifiers (`GMAtomic_*`, `GMReduction_*`, `GM_ATOM_*`,
and `GM_RED_*`) and the `PTO-ATOM-RED-*` NDF clause identities remain stable.
The existing `PTO-TILE-MGATHER-CAS` and
`PTO-BLOCK-BSTART-MGATHER-CAS` identities are the single canonical CAS
owners; the former `ATOM_CAS` active owner and separate legacy witness are
not retained in parallel.

This decision excludes Shared Tile, vector/packed forms, `f16x2`/`bf16x2`, and
U128, and supersedes only the selector-reservation consequence of ADR-0107.
The NDF implementation issue is GitHub issue 208.
