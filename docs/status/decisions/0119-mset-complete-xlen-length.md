---
{
  "id": "ADR-0119",
  "title": "Restore MSET complete-XLEN arbitrary length semantics",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "f2bb7bb3182f1ceec477c69409877e5e72d853f1",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-BLOCK-MSET-FILL-001",
    "PTO-INST-BLOCK-MSET"
  ],
  "affected_units": [
    "PTO-BLOCK-MSET",
    "PTO-BLOCK-MODEL-COMMIT-EFFECTS",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-SCALAR-MODEL-AGU-MEMORY"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/198",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0119: Restore MSET complete-XLEN arbitrary length semantics

## Context

`MSET` reads its destination, fill byte, and byte length from three absolute
GPRs.  The PTO model incorrectly converted the bounded reference
implementation into an architectural limit by rejecting every complete XLEN
length above 63.

Compiler-generated `memset` code legitimately supplies larger lengths.  A
1024-byte carrier therefore reached the canonical `MSET` encoding and raised
`Fault_IllegalInstruction` before its memory operation.

## Decision

- `RegSrc2` supplies the complete unsigned PTO_XLEN byte length.
- Zero length remains a successful memory-free no-op.
- Every nonzero, non-wrapping destination interval is eligible for the normal
  MSET data-access checks regardless of whether its length exceeds 63.
- A destination interval outside the active memory profile reports the
  existing data-access fault.  Length alone does not raise
  `Fault_IllegalInstruction`.
- The bounded reference model may use fixed storage and loop bounds to execute
  its supported address space.  Those bounds are model parameters and do not
  constrain portable PTO implementations.

The existing full-range preflight, increasing-address fill order, reservation
invalidation, last-command publication, and all-or-nothing fault behavior are
unchanged.  Hardware chunk size, cycle count, and internal implementation
mechanism remain unspecified.

## Compatibility

- Opcode, field locations, absolute-GPR selector domains, fill-byte selection,
  and sequential TPC behavior do not change.
- Lengths 0 through 63 retain their existing results.
- Lengths 64 and above change from unconditional IllegalInstruction to normal
  execution or the existing address/profile fault.

## Verification obligations

- An independent AVS point fills and verifies a range above 63 bytes.
- Zero-length, selector-rejection, reservation, and DataPage evidence remain
  green.
- The compiler-generated 1024-byte `memset` carrier crosses `MSET` without an
  IllegalInstruction caused only by its length.

## Decision state

The architecture owner explicitly restored the original complete-XLEN,
arbitrary-length MSET contract on 2026-09-01.
