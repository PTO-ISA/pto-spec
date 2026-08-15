# ADR-0021: Scalar PC-relative and return-address state

- Status: Accepted
- Date: 2026-07-29
- Requirement: PTO-REQ-SCALAR-CONTROL-001

## Context

PTO exposes TPC as the current scalar instruction address and names R10 as the
ABI return-address register. Earlier reference code accidentally gave `ADDTPC`
page-relative behavior and made `SETRET` update only an internal bundle-local
return target. Those effects conflicted with the instruction spellings and the
rest of the TPC execution contract.

## Decision

- `ADDTPC` and `HL.ADDTPC` compute `TPC + (sign-extended immediate << 1)`.
- `SETRET`, `HL.SETRET`, and `C.SETRET` compute `TPC + (immediate << 1)`.
- `SETRET` writes the computed target to architectural R10 (`ra`) and mirrors
  it into the bundle-local return-address state used by return bundle starts,
  frame handling, trap snapshots, and recovery.
- The canonical compressed spelling is `c.setret uimm, ->ra`. The malformed
  historical text `c.setret uimm, - >Ra` is not an accepted assembly alias and
  MUST NOT be emitted by canonical disassembly.
- Normal sequential TPC advancement remains the responsibility of the scalar
  dispatch boundary after the instruction effect completes.

## Consequences

PC-relative scalar arithmetic no longer inherits page-address semantics from
another ISA family. R10 and the bundle-local return target cannot silently
diverge after `SETRET`; later direct writes to R10 remain ordinary GPR writes
and do not retroactively change an already captured bundle return target.

The reviewed 548-form scalar-plus-command projection has SHA-256 fingerprint
`2d85b0ed94f4e2777b82400a996f938b154f66ee6630a74060da64e02b030e5e`.
Relative to the preceding fingerprint, only the canonical `C.SETRET` assembly
text changes; its form identity, width, mask, match, fields, constraints, and
execution encoding are unchanged.
