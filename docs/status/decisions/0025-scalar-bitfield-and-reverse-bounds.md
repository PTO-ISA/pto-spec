---
{
  "id": "ADR-0025",
  "title": "Scalar bitfield and byte-reversal bounds",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "zhoubot"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-BCNT-DECISION-BINDING-001",
    "PTO-BIC-DECISION-BINDING-001",
    "PTO-BIS-DECISION-BINDING-001",
    "PTO-BXS-DECISION-BINDING-001",
    "PTO-BXU-DECISION-BINDING-001",
    "PTO-CLZ-DECISION-BINDING-001",
    "PTO-CTZ-DECISION-BINDING-001",
    "PTO-REV-DECISION-BINDING-001",
    "PTO-HL-BFI-DECISION-BINDING-001",
    "PTO-INST-SCALAR-HL-BFI"
  ],
  "affected_units": [
    "PTO-SCALAR-BCNT",
    "PTO-SCALAR-BIC",
    "PTO-SCALAR-BIS",
    "PTO-SCALAR-BXS",
    "PTO-SCALAR-BXU",
    "PTO-SCALAR-CLZ",
    "PTO-SCALAR-CTZ",
    "PTO-SCALAR-REV",
    "PTO-SCALAR-HL-BFI",
    "PTO-SCALAR-MODEL-ALU-BITFIELD",
    "PTO-SCALAR-MODEL-ALU-SEMANTICS",
    "PTO-SCALAR-MODEL-DISPATCH-ALU"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [],
  "amendments": [
    {
      "date": "2026-09-01",
      "baseline": "b83b23930510c3ea96ec81b9838ce6c6a0929a4c",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/194",
      "affected_ndf": [
        "PTO-HL-BFI-DECISION-BINDING-001",
        "PTO-INST-SCALAR-HL-BFI"
      ],
      "affected_units": [
        "PTO-SCALAR-HL-BFI",
        "PTO-SCALAR-MODEL-ALU-BITFIELD",
        "PTO-SCALAR-MODEL-ALU-SEMANTICS",
        "PTO-SCALAR-MODEL-DISPATCH-ALU"
      ]
    }
  ]
}
---
# ADR 0025: Scalar bitfield and byte-reversal bounds

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

- Scope: scalar `BXS`, `BXU`, `BIC`, `BIS`, `CLZ`, `CTZ`, `BCNT`, `REV`, and `HL.BFI`

## Decision

For the scalar bitfield forms, the six-bit `imml` field encodes the field
width minus one, so every encoded value selects a width from 1 through 64.
The six-bit `imms` or `immr` field independently selects the least-significant
source bit from 0 through 63. A field that crosses bit 63 wraps to bit 0.

`REV` extracts the selected wrapping field and reverses its bytes into the low
bits of the result. Bits above the selected width are zero. A selected width
that is not a multiple of eight completes normally and returns zero; it is not
an illegal instruction and raises no fault. `imml` and `immr` remain independent
encoded operands and must not be collapsed or substituted for one another.

`HL.BFI` is byte-granular. `imms[2:0]` selects destination byte offset `M`, and
`immr[2:0]` encodes byte count `N` minus one. The operation snapshots both
sources, copies the low `N` bytes of `SrcR`, and replaces `N` bytes of `SrcL`
starting at byte `M`, wrapping modulo eight bytes. Encodings with either
six-bit field above seven are reserved and reject before source reads or
architectural effects.

All source values are read before the first destination write. Consequently,
an absolute or temporary-queue destination that aliases a source observes the
pre-instruction source value.

## Rationale

This disposition keeps the ordinary bitfield operands independent while
restoring the established byte-field interface of `HL.BFI`. The earlier
bit-granular `HL.BFI` ASL was an implementation defect, not a new interface
decision. Issue
[#194](https://github.com/PTO-ISA/pto-spec/issues/194) records the exact
compiler-shaped correction and evidence.

## Verification

`tests/asl/scalar/model/alu/semantics/scalar-bound-bitfield-contract-001.asl`
varies `imml` while holding `immr` fixed, varies
`immr` while holding `imml` fixed, exercises minimum, byte-aligned, wrapping,
non-byte, and full-width selections, and uses an aliased source/destination.
The catalog checker requires this ADR and the decoded boundary witness to remain
traceable from `PTO-REQ-SCALAR-ALU-001`.
