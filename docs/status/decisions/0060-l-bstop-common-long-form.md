---
{
  "id": "ADR-0060",
  "title": "Restore `L.BSTOP` as the common 64-bit bundle stop",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-11",
  "accepted": "2026-08-11",
  "rejected": null,
  "superseded": null,
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1"
  ],
  "affected_ndf": [
    "PTO-L-BSTOP-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-BLOCK-L-BSTOP"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0060: Restore `L.BSTOP` as the common 64-bit bundle stop

- Date: 2026-08-11
- Requirements: PTO-REQ-BUNDLE-DISPATCH-001,
  PTO-REQ-BUNDLE-OPERATION-001, PTO-REQ-BUNDLE-STATE-001

Current release inventory is governed by ASL and generated projections;
numeric inventories below are acceptance-time history, not the current active
decoder set.

## Context

PTO requires compressed, base-width, and long bundle-stop encodings with one
shared commit operation. The 64-bit form was missing from the executable
catalog even though its two-word encoding and distinct canonical mnemonic had
already been selected. Omitting it would leave that 64-bit encoding without a
PTO owner.

## Decision

`L.BSTOP` is an accepted PTO instruction. Its encoding MUST be the
two exact 32-bit words below, in instruction-address order:

| Word | Mask | Match |
| --- | --- | --- |
| low | `0xffffffff` | `0x0000000f` |
| high | `0xffffffff` | `0x00000001` |

No bit in either word is an operand field. Any different bit pattern is not an
`L.BSTOP` encoding and MUST be decoded independently or rejected before
`L.BSTOP` effects.

After successful decode, `L.BSTOP` MUST execute the same normative
`ExecuteBundleStop` operation as `BSTOP` and `C.BSTOP`: it commits the current
bundle and transfers to the bundle's selected continuation. The mnemonic MUST
remain distinct in canonical assembly and disassembly; tools MUST NOT
normalize it to either shorter form.

The PTO command catalog MUST append stable form ID
`l_bstop_64_94c7f0a5e8b3`. Every PTO decoder, assembler, disassembler, AVS
point, generated page, and release projection MUST expose the same two-word
encoding and `ExecuteBundleStop` handler identity.

## Consequences

- At acceptance time, the common command-form inventory increased from 99 to
  100 and the encoded scalar-plus-command envelope increased from 573 to 574
  forms.
- The acceptance-time 574-form binary-closure fingerprint was
  `6d0814b26ed0db560395752a53f4403c0ff000d7c5cf2a7a87ec42048c25678b`.
- PTO decoder, assembly, disassembly, AVS, generated documentation, and release
  projections MUST include `L.BSTOP`.
- The existing `C.BSTOP` and `BSTOP` encodings and semantics are unchanged.
- The manual semantic audit may continue only after both executable catalogs
  agree with this decision and their exact common form is verified.

## Evidence

- `asl/block/lifecycle/L.BSTOP.asl`
- `spec/catalog/command-forms.json`
- `tests/asl/block/lifecycle/L.BSTOP/`
