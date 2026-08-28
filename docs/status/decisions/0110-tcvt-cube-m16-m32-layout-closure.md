---
{
  "id": "ADR-0110",
  "title": "TCVT CUBE_M16 and CUBE_M32 layout closure",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-08-28",
  "accepted": "2026-08-28",
  "rejected": null,
  "superseded": null,
  "baseline": "93a4b9e34c0bd80767077b41dac85b26b3e59934",
  "target_releases": ["0.58.5"],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-INST-TILE-TCVT",
    "PTO-TCVT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE",
    "PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION",
    "PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA",
    "PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA",
    "PTO-TILE-MODEL-NUMERIC-FORMATS",
    "PTO-TILE-TCVT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/167",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0110: TCVT CUBE_M16 and CUBE_M32 layout closure

## Context

Issue #167 closes the TCVT destination-layout contract for Matrix `CUBE_M16`
and `CUBE_M32` sources. The implementation is based on the frozen issue
contract at baseline `52befcc1d6be2907708381b930a4eaf0242c204c` and keeps the
existing private CUBE representation boundary separate.

## Decision

For a Matrix source with `Layout=NORM` and `Canonicalize=0`, `TCVT` maps
`CUBE_M16` to `CUBE_M16` and `CUBE_M32` to `CUBE_M32`. The destination keeps
the source `valid_rows` and `valid_columns`, while its physical shape, CELL
count, required bytes, and minimum legal TSize are independently derived from
the destination `DataType`; the destination TSize may differ from the source
TSize.

The CUBE M-format path requires Matrix location, `Layout=NORM`, and
`Canonicalize=0`. Private CUBE canonicalization remains a separate
`Canonicalize=1` representation boundary. `CUBE_N8` is outside this decision.
For this path LB0 and LB1 must equal the source `ValidCol` and `ValidRow`;
LB1 omission still selects one row. LB2 must be omitted because CUBE physical
columns are derived independently for each DataType and TSize. Any mismatch or
present LB2 raises `Fault_TileLegality` before destination allocation. Once the
logical shape is accepted, an insufficient destination TSize raises
`Fault_TileAllocation` with no destination effect.

For example, a `CUBE_M16` FP32 source with `ValidRow=16`, `ValidCol=1`, and
TSize 128 B may convert to BF16 with the same valid region and TSize 128 B.
The source and destination logical payloads are 64 B and 32 B, respectively;
their remaining physical coordinates are padding. With `PadValue=Null`, every
destination padding coordinate remains undefined.
Local destination capacity continues to require 128-byte alignment, a capacity
between 128 B and 64 KiB inclusive, the PE limit, and enough bytes for the
target descriptor. TCVT remains a per-logical-element conversion; this ADR
introduces no FP16x2/FP8x2 pair DataType and no pair opcode.

## Release boundary

This accepted ADR is targeted to PTO ISA `0.58.5` and is a release-boundary
record for the issue #167 NDF and ASL drift. Current semantic meaning remains
owned by the affected ASL/NDF clauses and their generated projections.
