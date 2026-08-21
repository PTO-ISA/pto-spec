---
{
  "id": "ADR-0024",
  "title": "PC-relative and unscaled AGU addressing",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-HL-SD-UPO-DECISION-BINDING-001",
    "PTO-HL-SD-UPR-DECISION-BINDING-001",
    "PTO-HL-SH-UPO-DECISION-BINDING-001",
    "PTO-HL-SH-UPR-DECISION-BINDING-001",
    "PTO-HL-SW-UPO-DECISION-BINDING-001",
    "PTO-HL-SW-UPR-DECISION-BINDING-001",
    "PTO-SH-PCR-ADR-CONTRACT-001",
    "PTO-SW-PCR-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-SCALAR-HL-LB-PCR",
    "PTO-SCALAR-HL-LBU-PCR",
    "PTO-SCALAR-HL-LD-PCR",
    "PTO-SCALAR-HL-LH-PCR",
    "PTO-SCALAR-HL-LHU-PCR",
    "PTO-SCALAR-HL-LW-PCR",
    "PTO-SCALAR-HL-LWU-PCR",
    "PTO-SCALAR-HL-SB-PCR",
    "PTO-SCALAR-HL-SD-PCR",
    "PTO-SCALAR-HL-SD-UPO",
    "PTO-SCALAR-HL-SD-UPR",
    "PTO-SCALAR-HL-SH-PCR",
    "PTO-SCALAR-HL-SH-UPO",
    "PTO-SCALAR-HL-SH-UPR",
    "PTO-SCALAR-HL-SW-PCR",
    "PTO-SCALAR-HL-SW-UPO",
    "PTO-SCALAR-HL-SW-UPR",
    "PTO-SCALAR-LB-PCR",
    "PTO-SCALAR-LBU-PCR",
    "PTO-SCALAR-LD-PCR",
    "PTO-SCALAR-LH-PCR",
    "PTO-SCALAR-LHU-PCR",
    "PTO-SCALAR-LW-PCR",
    "PTO-SCALAR-LWU-PCR",
    "PTO-SCALAR-SB-PCR",
    "PTO-SCALAR-SD-PCR",
    "PTO-SCALAR-SH-PCR",
    "PTO-SCALAR-SW-PCR"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0024: PC-relative and unscaled AGU addressing

- Scope: scalar AGU PC-relative and register-offset writeback forms

## Decision

Scalar PC-relative load and store forms align the current TPC down to a
four-byte boundary before adding their signed, four-byte-scaled displacement.
This rule matters when a 32-bit or 48-bit PC-relative form begins at a
halfword-aligned address whose bit 1 is set.

The six register-offset store-writeback forms `HL.SH.UPR`, `HL.SH.UPO`,
`HL.SW.UPR`, `HL.SW.UPO`, `HL.SD.UPR`, and `HL.SD.UPO` are genuinely
unscaled. Their modified register offset is added directly; it is not scaled by
the access width. Pre-index forms access the updated address and post-index
forms access the original base before publishing the same updated address.

## Rationale

Four-byte alignment gives PC-relative displacement encoding a stable base even
when variable-length scalar instructions place the current TPC on the other
halfword of a word. The `.U` marker on the six writeback stores distinguishes
them from their scaled register-offset counterparts and must remain observable
with a nonzero offset.

## Verification

Decoded PC-relative witnesses use a TPC with bit 1 set and assert an address
derived from the aligned base. Decoded witnesses for all six `.UPR/.UPO` forms
use nonzero offsets that distinguish unscaled from access-width-scaled
addresses and check both memory and writeback state.
