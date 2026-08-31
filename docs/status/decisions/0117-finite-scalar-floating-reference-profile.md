---
{
  "id": "ADR-0117",
  "title": "Bind finite scalar FP32 and FP64 pto-v0 reference semantics",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "03e57c9a7d1da65ed492a962c2ac25bb26432b4c",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-FADD-DECISION-BINDING-001",
    "PTO-FCVT-DECISION-BINDING-001",
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-FCVTM-DECISION-BINDING-001",
    "PTO-FCVTN-DECISION-BINDING-001",
    "PTO-FCVTP-DECISION-BINDING-001",
    "PTO-FCVTZ-DECISION-BINDING-001",
    "PTO-FDIV-DECISION-BINDING-001",
    "PTO-FEXP-DECISION-BINDING-001",
    "PTO-FMADD-DECISION-BINDING-001",
    "PTO-FMSUB-DECISION-BINDING-001",
    "PTO-FMUL-DECISION-BINDING-001",
    "PTO-FNMADD-DECISION-BINDING-001",
    "PTO-FNMSUB-DECISION-BINDING-001",
    "PTO-FRECIP-DECISION-BINDING-001",
    "PTO-FSQRT-DECISION-BINDING-001",
    "PTO-FSUB-DECISION-BINDING-001",
    "PTO-INST-SCALAR-FADD",
    "PTO-INST-SCALAR-FCVT",
    "PTO-INST-SCALAR-FCVTA",
    "PTO-INST-SCALAR-FCVTM",
    "PTO-INST-SCALAR-FCVTN",
    "PTO-INST-SCALAR-FCVTP",
    "PTO-INST-SCALAR-FCVTZ",
    "PTO-INST-SCALAR-FDIV",
    "PTO-INST-SCALAR-FEXP",
    "PTO-INST-SCALAR-FMADD",
    "PTO-INST-SCALAR-FMSUB",
    "PTO-INST-SCALAR-FMUL",
    "PTO-INST-SCALAR-FNMADD",
    "PTO-INST-SCALAR-FNMSUB",
    "PTO-INST-SCALAR-FRECIP",
    "PTO-INST-SCALAR-FSQRT",
    "PTO-INST-SCALAR-FSUB",
    "PTO-INST-SCALAR-SCVTF",
    "PTO-INST-SCALAR-UCVTF",
    "PTO-SCVTF-DECISION-BINDING-001",
    "PTO-UCVTF-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION",
    "PTO-SCALAR-FADD",
    "PTO-SCALAR-FCVT",
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-FCVTM",
    "PTO-SCALAR-FCVTN",
    "PTO-SCALAR-FCVTP",
    "PTO-SCALAR-FCVTZ",
    "PTO-SCALAR-FDIV",
    "PTO-SCALAR-FEXP",
    "PTO-SCALAR-FMADD",
    "PTO-SCALAR-FMSUB",
    "PTO-SCALAR-FMUL",
    "PTO-SCALAR-FNMADD",
    "PTO-SCALAR-FNMSUB",
    "PTO-SCALAR-FRECIP",
    "PTO-SCALAR-FSQRT",
    "PTO-SCALAR-FSUB",
    "PTO-SCALAR-SCVTF",
    "PTO-SCALAR-UCVTF"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/196",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0117: Bind finite scalar FP32 and FP64 pto-v0 reference semantics

## Context

Scalar FSU instruction contracts select an active numeric profile, but the
pto-v0 reference implementation and mnemonic state-effect text retained
integer and identity placeholders. Finite FP32 and FP64 programs therefore
decoded and retired normally while publishing non-floating results.

The profile boundary already owns rounding selection, carrier normalization,
sticky status publication, NaN classification, signed-zero ordering, and
conversion dispatch. The missing closure is the finite carrier value path.

## Decision

For finite FP32 and FP64 carriers, pto-v0:

- decodes binary32 and binary64 carrier encodings to mathematical values;
- executes the selected binary, unary, fused, reciprocal, square-root,
  exponential, and conversion operation through the existing profile hook;
- encodes the result into the selected FP32 or FP64 carrier using the selected
  rounding mode and publishes the resulting numeric status flags;
- preserves the instruction-owned NaN, signaling-NaN, signed-zero, min/max,
  type legality, source snapshot, destination, and fault-ordering rules.

Other floating carrier formats retain their existing explicit profile hooks
and are not silently treated as FP32 or FP64.

## Compatibility

- Instruction encodings, assembly, register selection, and block placement do
  not change.
- Finite FP32 and FP64 results now match the declared floating operations
  instead of the removed integer/identity placeholders.
- Existing NaN, infinity, signed-zero, rounding-control, and sticky-status
  boundaries remain owned by their current instruction and profile contracts.
- ELF loading, worker transport, C ABI, stop policy, and host performance are
  outside this architecture decision.

## Verification obligations

- FP32 and FP64 finite decode/encode round trips cover positive and negative
  values, subnormal boundaries, and selected rounding modes.
- FADD, FSUB, FMUL, FDIV, FSQRT, FRECIP, fused operations, and conversions have
  executable focused evidence.
- Existing NaN, signed-zero, min/max, type, alias, and sticky-flag tests remain
  green.
- Real scalar FP ELF cases match independent result goldens.

## Decision state

The architecture owner authorized autonomous detailed analysis and the
recommended architecture rule on 2026-09-01. Focused FP32, FP64, conversion,
rounding, mnemonic-direct, and real ELF evidence bind the selected profile.
