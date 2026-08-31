---
{
  "id": "ADR-0118",
  "title": "Assign CSEL raw selector 10 to false-source negation",
  "status": "draft",
  "authors": ["Codex"],
  "approvers": [],
  "created": "2026-09-01",
  "accepted": null,
  "rejected": null,
  "superseded": null,
  "baseline": "622f99f9743ecaf62ef1c1b4f5e5a70f44427428",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-INST-SCALAR-CSEL"
  ],
  "affected_units": [
    "PTO-SCALAR-CSEL",
    "PTO-SCALAR-MODEL-DISPATCH-DECODE"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/197",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0118: Assign CSEL raw selector 10 to false-source negation

## Context

`CSEL` has three source operands and a two-bit modifier for its false source.
The 0.58.5 binary contract uses raw selector `10` for `.neg` and emits raw
selector `11` for the ordinary unmodified spelling.

PTO-SPEC assigned negation to `11`. A compiler-generated scalar absolute-value
loop therefore negated its positive false value and published a negative
result when the predicate was false.

## Decision

For `CSEL` only:

- raw `10` negates the complete PTO_XLEN false source modulo 2^PTO_XLEN;
- raw `00`, `01`, and `11` leave the false source unchanged;
- predicate zero selects the prepared false source and every nonzero predicate
  selects the complete true source.

All three sources remain eagerly validated and snapshotted before destination
publication, including the source not selected by the predicate.

## Compatibility

- Opcode, field locations, assembly operands, predicate direction, destination
  mapping, and sequential TPC behavior do not change.
- Ordinary compiler-generated CSEL encodings with raw `11` now preserve SrcR.
- Raw `10` is the only `.neg` encoding.
- Binaries relying on the conflicting PTO selector assignment change meaning
  and are not 0.58.5-compatible inputs.

## Verification obligations

- All four raw selector values have explicit expected results.
- Exact compiler encoding `0xcfcc0177` selects an unmodified U#1 false source.
- True and false relative-source paths retain eager readiness and alias rules.
- Scalar FP32/FP64 absolute-value ELF cases match independent goldens.

## Decision state

The architecture owner authorized autonomous detailed analysis and the
recommended architecture rule on 2026-09-01. This draft binds the exact
baseline before implementation and focused evidence promote it to accepted.
