---
{
  "id": "ADR-0121",
  "title": "Restore FP-to-integer raw DstType encoding",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "62948f7dde41a4ede05fe424648ef3372fe220e6",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-FCVTM-DECISION-BINDING-001",
    "PTO-FCVTN-DECISION-BINDING-001",
    "PTO-FCVTP-DECISION-BINDING-001",
    "PTO-FCVTZ-DECISION-BINDING-001",
    "PTO-INST-SCALAR-FCVTA",
    "PTO-INST-SCALAR-FCVTM",
    "PTO-INST-SCALAR-FCVTN",
    "PTO-INST-SCALAR-FCVTP",
    "PTO-INST-SCALAR-FCVTZ"
  ],
  "affected_units": [
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-FCVTM",
    "PTO-SCALAR-FCVTN",
    "PTO-SCALAR-FCVTP",
    "PTO-SCALAR-FCVTZ",
    "PTO-SCALAR-MODEL-DISPATCH-FSU",
    "PTO-SCALAR-MODEL-FSU-PROFILE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/205",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0121: Restore FP-to-integer raw DstType encoding

## Context

The established FP-to-integer compiler contract assigns raw DstType values 0 through
3 to unsigned 64-, 32-, 16-, and 8-bit results and values 4 through 7 to the
corresponding signed results.  Values above seven are reserved.

PTO treated the raw field as its generic internal integer carrier code and
accepted values 0 through 14.  Exact compiler encoding `0x220c5feb`,
`fcvtz.fs2sd`, therefore interpreted raw four as an unsigned four-bit result;
FP32 16.0 became zero instead of signed 16.

## Decision

For FCVTA, FCVTM, FCVTN, FCVTP, and FCVTZ:

- raw 0, 1, 2, and 3 select UD, UW, UH, and UB;
- raw 4, 5, 6, and 7 select SD, SW, SH, and SB;
- raw 8 through 31 are reserved and reject before source readiness, reads,
  numeric-profile calls, flags, destinations, queues, or TPC effects;
- decode maps raw 0 through 3 to canonical unsigned carrier codes 0 through 3
  and raw 4 through 7 to canonical signed carrier codes 8 through 11 before
  invoking the numeric profile.

SrcType support remains the current PTO finite-profile FP64/FP32 domain.  Any
future FP16 or FP8 source expansion is a separate architecture decision.

## Compatibility

- Opcode, field location, rounding selection, source and destination register
  selectors, flag accumulation, and TPC behavior do not change.
- Raw 0 through 3 retain their unsigned meanings.
- Raw 4 through 7 regain the signed meanings used by existing compiler output.
- Raw 8 through 14 change from incorrectly accepted generic carrier codes to
  reserved encodings.

## Verification obligations

- Every raw DstType value 0 through 7 has an exact canonical type witness.
- Every raw value 8 through 31 rejects before architectural effects.
- Exact raw `0x220c5feb` converts FP32 16.0 to signed 64-bit 16.
- The compiler SCVTF/FMADD/FCVTZ stream and memory corpus carrier match their
  independent goldens across the FP32 16.0 boundary.

## Decision state

The architecture owner confirmed this encoding correction on 2026-09-01.
