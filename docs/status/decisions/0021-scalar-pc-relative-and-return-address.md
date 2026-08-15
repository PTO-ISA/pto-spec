# ADR-0021: Scalar PC-relative and return-address state

- Status: Accepted
- Date: 2026-07-29
- Requirement: PTO-REQ-SCALAR-CONTROL-001

> The ADDTPC and HL.ADDTPC rule in this record is superseded and narrowed by
> [ADR 0065](0065-addtpc-page-scaling-correction.md). The SETRET rules below
> remain in force.

## Context

PTO exposes TPC as the current scalar instruction address and names R10 as the
ABI return-address register. Earlier reference code accidentally gave `ADDTPC`
page-relative behavior and made `SETRET` update only an internal bundle-local
return target. Those effects conflicted with the instruction spellings and the
rest of the TPC execution contract.

## Decision

- `ADDTPC` and `HL.ADDTPC` compute `TPC + (sign-extended immediate << 12)`;
  this correction is owned by ADR 0065.
- `SETRET`, `HL.SETRET`, and `C.SETRET` compute `TPC + (immediate << 1)`.
- `SETRET` writes the computed target to architectural R10 (`ra`) and mirrors
  it into the bundle-local return-address state used by return bundle starts,
  frame handling, trap snapshots, and recovery.
- Normal sequential TPC advancement remains the responsibility of the scalar
  dispatch boundary after the instruction effect completes.

## Consequences

PC-relative scalar arithmetic no longer inherits page-address semantics from
another ISA family. R10 and the bundle-local return target cannot silently
diverge after `SETRET`; later direct writes to R10 remain ordinary GPR writes
and do not retroactively change an already captured bundle return target.
