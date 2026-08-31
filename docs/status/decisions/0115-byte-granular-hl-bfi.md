---
{
  "id": "ADR-0115",
  "title": "Define HL.BFI as byte-granular insertion",
  "status": "draft",
  "authors": ["Codex"],
  "approvers": [],
  "created": "2026-09-01",
  "accepted": null,
  "rejected": null,
  "superseded": null,
  "baseline": "c0c85094e15ac1507eb36ffe7fe13e60aa7bac32",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-HL-BFI-DECISION-BINDING-001",
    "PTO-INST-SCALAR-HL-BFI"
  ],
  "affected_units": [
    "PTO-SCALAR-HL-BFI",
    "PTO-SCALAR-MODEL-ALU-SEMANTICS",
    "PTO-SCALAR-MODEL-DISPATCH-ALU"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/194",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0115: Define HL.BFI as byte-granular insertion

## Context

`HL.BFI SrcL, SrcR, M, N` is the long scalar byte-field insertion operation.
The 0.58.5 binary contract uses it to materialize repeated byte groups, such as
copying a low four-byte value into the high four bytes of an XLEN word.

PTO-SPEC instead interpreted the two six-bit fields as an inclusive wrapping
bit interval. Under that interpretation, the encoded `M=4, N=4` operation
modified only a small bit interval and corrupted initialized data before the
program's measured loop began.

## Decision

`HL.BFI` is byte-granular:

- `imms` encodes destination byte offset `M` in the range 0 through 7.
- `immr` encodes `N-1`, where byte count `N` is in the range 1 through 8.
- The operation snapshots both sources, copies the low `N` bytes of `SrcR`,
  and replaces `N` bytes of `SrcL` beginning at byte `M`.
- Destination byte selection wraps modulo eight bytes. Source bytes are used
  in ascending order from source byte zero.
- `imms > 7` or `immr > 7` is reserved and raises illegal instruction before
  source readiness, reads, destination publication, or TPC advancement.

## Compatibility

- The 48-bit opcode, field locations, assembly spelling, and destination map
  do not change.
- Existing 0.58.5 encodings using `M=4, N=4` and `M=3, N=3` now produce the
  intended repeated-byte constants.
- Encodings outside the assigned byte ranges become explicitly reserved.
- Queue source readiness, alias snapshots, and sequential TPC behavior remain
  unchanged.

## Verification obligations

- `M=4, N=4` duplicates a low 32-bit value into both XLEN halves.
- `M=7, N=2` wraps the second inserted byte to destination byte zero.
- `M=0, N=8` replaces the complete XLEN destination.
- Reserved `M` and `N-1` encodings fault before architectural effects.
- The exact compiler-shaped initialization and loop sequence produces the
  independent scalar result.

## Decision state

The architecture owner authorized autonomous detailed analysis and the
recommended architecture rule on 2026-09-01. This draft binds the exact
baseline before implementation and focused evidence promote it to accepted.
