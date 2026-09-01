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
    "PTO-INST-BLOCK-BSTART-ATOM-ADD",
    "PTO-INST-BLOCK-BSTART-ATOM-AND",
    "PTO-INST-BLOCK-BSTART-ATOM-CAS",
    "PTO-INST-BLOCK-BSTART-ATOM-DEC",
    "PTO-INST-BLOCK-BSTART-ATOM-EXCH",
    "PTO-INST-BLOCK-BSTART-ATOM-INC",
    "PTO-INST-BLOCK-BSTART-ATOM-MAX",
    "PTO-INST-BLOCK-BSTART-ATOM-MIN",
    "PTO-INST-BLOCK-BSTART-ATOM-OR",
    "PTO-INST-BLOCK-BSTART-ATOM-XOR",
    "PTO-INST-BLOCK-BSTART-MGATHER-CAS",
    "PTO-INST-BLOCK-BSTART-RED-ADD",
    "PTO-INST-BLOCK-BSTART-RED-AND",
    "PTO-INST-BLOCK-BSTART-RED-DEC",
    "PTO-INST-BLOCK-BSTART-RED-INC",
    "PTO-INST-BLOCK-BSTART-RED-MAX",
    "PTO-INST-BLOCK-BSTART-RED-MIN",
    "PTO-INST-BLOCK-BSTART-RED-OR",
    "PTO-INST-BLOCK-BSTART-RED-POPC",
    "PTO-INST-BLOCK-BSTART-RED-XOR",
    "PTO-INST-TILE-ATOM-ADD",
    "PTO-INST-TILE-ATOM-AND",
    "PTO-INST-TILE-ATOM-CAS",
    "PTO-INST-TILE-ATOM-DEC",
    "PTO-INST-TILE-ATOM-EXCH",
    "PTO-INST-TILE-ATOM-INC",
    "PTO-INST-TILE-ATOM-MAX",
    "PTO-INST-TILE-ATOM-MIN",
    "PTO-INST-TILE-ATOM-OR",
    "PTO-INST-TILE-ATOM-XOR",
    "PTO-INST-TILE-RED-ADD",
    "PTO-INST-TILE-RED-AND",
    "PTO-INST-TILE-RED-DEC",
    "PTO-INST-TILE-RED-INC",
    "PTO-INST-TILE-RED-MAX",
    "PTO-INST-TILE-RED-MIN",
    "PTO-INST-TILE-RED-OR",
    "PTO-INST-TILE-RED-POPC",
    "PTO-INST-TILE-RED-XOR",
    "PTO-MGATHER-CAS-ATOMIC-001",
    "PTO-MGATHER-CAS-PUBLICATION-001"
  ],
  "affected_units": [
    "PTO-BLOCK-BSTART-ATOM-ADD",
    "PTO-BLOCK-BSTART-ATOM-AND",
    "PTO-BLOCK-BSTART-ATOM-CAS",
    "PTO-BLOCK-BSTART-ATOM-DEC",
    "PTO-BLOCK-BSTART-ATOM-EXCH",
    "PTO-BLOCK-BSTART-ATOM-INC",
    "PTO-BLOCK-BSTART-ATOM-MAX",
    "PTO-BLOCK-BSTART-ATOM-MIN",
    "PTO-BLOCK-BSTART-ATOM-OR",
    "PTO-BLOCK-BSTART-ATOM-XOR",
    "PTO-BLOCK-BSTART-MGATHER-CAS",
    "PTO-BLOCK-BSTART-RED-ADD",
    "PTO-BLOCK-BSTART-RED-AND",
    "PTO-BLOCK-BSTART-RED-DEC",
    "PTO-BLOCK-BSTART-RED-INC",
    "PTO-BLOCK-BSTART-RED-MAX",
    "PTO-BLOCK-BSTART-RED-MIN",
    "PTO-BLOCK-BSTART-RED-OR",
    "PTO-BLOCK-BSTART-RED-POPC",
    "PTO-BLOCK-BSTART-RED-XOR",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-TILE-ATOM-ADD",
    "PTO-TILE-ATOM-AND",
    "PTO-TILE-ATOM-CAS",
    "PTO-TILE-ATOM-DEC",
    "PTO-TILE-ATOM-EXCH",
    "PTO-TILE-ATOM-INC",
    "PTO-TILE-ATOM-MAX",
    "PTO-TILE-ATOM-MIN",
    "PTO-TILE-ATOM-OR",
    "PTO-TILE-ATOM-XOR",
    "PTO-TILE-MGATHER-CAS",
    "PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT",
    "PTO-TILE-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA",
    "PTO-TILE-MODEL-MEMORY-ATOMICS",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION",
    "PTO-TILE-RED-ADD",
    "PTO-TILE-RED-AND",
    "PTO-TILE-RED-DEC",
    "PTO-TILE-RED-INC",
    "PTO-TILE-RED-MAX",
    "PTO-TILE-RED-MIN",
    "PTO-TILE-RED-OR",
    "PTO-TILE-RED-POPC",
    "PTO-TILE-RED-XOR"
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

Add the GM-only indexed `atom.*` and `red.*` operation families on TLSU
Functions 8--27 using the fixed low carrier `0x11181`, mask `0x07ffffff`, and
no bit-25 expansion. Function 8 remains the binary selector for `atom.cas` and
the legacy `MGATHER.CAS` spelling, but its accepted DataTypes are intentionally
narrowed to `U16`, `U32`, and `U64`; `U128` and non-U CAS types fault
`Fault_TileLegality`.

Atom forms return their per-request old value in a destination tile. Red forms
have no destination; `red.popc` has no ValueTile and contributes one U32 update
per valid effective address. Every request is intrinsically atomic, duplicate
addresses serialize in implementation-defined order, and all addresses are
preflighted before effects. Floating ADD uses the frozen PTX-derived GM profile.

This decision excludes Shared Tile, vector/packed forms, `f16x2`/`bf16x2`, and
U128, and supersedes only the selector-reservation consequence of ADR-0107.
The NDF implementation issue is GitHub issue 208.
