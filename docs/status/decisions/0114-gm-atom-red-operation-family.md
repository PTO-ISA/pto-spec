---
{
  "id": "ADR-0114",
  "title": "GM atom/red operation family",
  "status": "accepted",
  "authors": ["PTO ISA maintainers"],
  "approvers": ["PTO ISA maintainers"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "e811355419182144784af802ff4c86d6a7014c70",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-ATOM-RED-ENCODING-001",
    "PTO-ATOM-RED-BODY-SCHEMA-001",
    "PTO-ATOM-RED-TYPE-LEGALITY-001",
    "PTO-ATOM-RED-INC-DEC-SEMANTICS-001",
    "PTO-ATOM-RED-POPC-SEMANTICS-001",
    "PTO-ATOM-RED-ORDERING-001",
    "PTO-ATOM-RED-FAULTS-001"
  ],
  "affected_units": [
    "PTO-TILE-MODEL-MEMORY-GM-ATOM-RED",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-GM-ATOM-RED",
    "PTO-TILE-MGATHER-CAS",
    "PTO-BLOCK-BSTART-ATOM-CAS",
    "PTO-BLOCK-BSTART-ATOM-EXCH",
    "PTO-BLOCK-BSTART-ATOM-MAX",
    "PTO-BLOCK-BSTART-ATOM-MIN",
    "PTO-BLOCK-BSTART-ATOM-ADD",
    "PTO-BLOCK-BSTART-ATOM-INC",
    "PTO-BLOCK-BSTART-ATOM-DEC",
    "PTO-BLOCK-BSTART-ATOM-AND",
    "PTO-BLOCK-BSTART-ATOM-OR",
    "PTO-BLOCK-BSTART-ATOM-XOR",
    "PTO-BLOCK-BSTART-RED-MAX",
    "PTO-BLOCK-BSTART-RED-MIN",
    "PTO-BLOCK-BSTART-RED-ADD",
    "PTO-BLOCK-BSTART-RED-INC",
    "PTO-BLOCK-BSTART-RED-DEC",
    "PTO-BLOCK-BSTART-RED-AND",
    "PTO-BLOCK-BSTART-RED-OR",
    "PTO-BLOCK-BSTART-RED-XOR",
    "PTO-BLOCK-BSTART-RED-POPC"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/208",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0114: GM atom/red operation family

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
