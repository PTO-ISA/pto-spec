---
{
  "id": "ADR-0112",
  "title": "Warning-free ASLRef constraint refinements",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-08-29",
  "accepted": "2026-08-29",
  "rejected": null,
  "superseded": null,
  "baseline": "e945b41dacaac5fd678639cc76ca82c7836974f0",
  "target_releases": ["0.58.5"],
  "release_boundary": true,
  "affected_ndf": [
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-HL-QPOP-GQM-001",
    "PTO-HL-QPUSH-GQM-001"
  ],
  "affected_units": [
    "PTO-ARCH-GQM",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-HL-QPOP",
    "PTO-BLOCK-HL-QPUSH",
    "PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0112: Warning-free ASLRef constraint refinements

## Context

Strict ASLRef type checking accepted the PTO model but emitted three warnings.
Two warnings arose because queue capacity is declared with zero in its storage
type even though successful queue initialization and the existing early-return
paths guarantee a nonzero capacity before either modulo expression. The third
arose because `BundleFPATRGroupN` includes the disabled value zero even though
`BundleGroupMaxColumns` returns before division whenever that value is selected.

These warnings conceal future constraint regressions and make a warning-free
strict check impossible. They do not identify an architecture decision gap:
the accepted GQM and B.FPATR behavior already excludes the warned divisor-zero
paths before the affected arithmetic is evaluated.

## Decision

After each existing terminating guard, the ASL owner introduces a typed local
whose constraint contains only the values permitted on the continuing path.
GQM push and pop use a `capacity` local constrained to
`1..PTO_GQM_MAX_CAPACITY`. Group-maximum column derivation uses a
`nonzero_group_n` local constrained to the nine assigned nonzero GroupN values.

The refinements do not change a condition, result, effect order, fault, queue
state transition, group-size mapping, encoding, or portable profile choice.
They expose facts already established by the preceding control flow so ASLRef
can prove the modulo and division operations total on those paths.

The repository strict-check entry point rejects any successful ASLRef run that
still emits `ASL Warning:`. It also preserves the original ASLRef failure status
and diagnostics. This is a validation policy: it does not reinterpret warnings
as PTO architectural behavior.

## Verification

- GQM push/pop focused execution remains unchanged across the refinement.
- B.FPATR group-maximum boundary results remain unchanged for disabled, exact,
  rounded-up, and maximum assigned group sizes.
- Full strict ASLRef type checking emits zero warnings.
- Wrapper canaries prove warning-free success, warning rejection, and original
  failure-status preservation.
- Repository and binary-closure checks remain unchanged.

## Release boundary

This accepted record covers the same-publication ASL unit drift for PTO ISA
`0.58.5`. Current semantic meaning remains owned exclusively by the affected
ASL/NDF clauses; this maintenance decision adds no second normative definition.
