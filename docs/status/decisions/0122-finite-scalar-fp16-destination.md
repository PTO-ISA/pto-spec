---
{
  "id": "ADR-0122",
  "title": "Complete scalar conversion and shared Tile conversion semantics",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["zhoubot"],
  "created": "2026-09-01",
  "accepted": "2026-09-01",
  "rejected": null,
  "superseded": null,
  "baseline": "54429a8f1c40d9260352a903d2a9726b59842486",
  "target_releases": ["0.58.5"],
  "affected_ndf": [
    "PTO-COMMON-CONVERSION-PROFILE-001",
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-FCVTM-DECISION-BINDING-001",
    "PTO-FCVTN-DECISION-BINDING-001",
    "PTO-FCVTP-DECISION-BINDING-001",
    "PTO-FCVTZ-DECISION-BINDING-001",
    "PTO-INST-SCALAR-FCVT",
    "PTO-INST-SCALAR-FCVTA",
    "PTO-INST-SCALAR-FCVTM",
    "PTO-INST-SCALAR-FCVTN",
    "PTO-INST-SCALAR-FCVTP",
    "PTO-INST-SCALAR-FCVTZ",
    "PTO-INST-SCALAR-SCVTF",
    "PTO-INST-SCALAR-UCVTF",
    "PTO-SCVTF-DECISION-BINDING-001",
    "PTO-TCVT-CONTRACT-001",
    "PTO-UCVTF-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-E8M0-CONVERSION",
    "PTO-ARCH-PROFILE-MATRIX-QUANTIZATION",
    "PTO-ARCH-PROFILE-REFERENCE-CONVERSION",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION",
    "PTO-SCALAR-FCVT",
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-FCVTM",
    "PTO-SCALAR-FCVTN",
    "PTO-SCALAR-FCVTP",
    "PTO-SCALAR-FCVTZ",
    "PTO-SCALAR-MODEL-DISPATCH-FSU",
    "PTO-SCALAR-MODEL-FSU-PROFILE",
    "PTO-SCALAR-SCVTF",
    "PTO-SCALAR-UCVTF",
    "PTO-TILE-MODEL-NUMERIC-FORMATS",
    "PTO-TILE-TCVT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/206",
  "release_impact": "required",
  "legacy_ids": []
}
---

# ADR 0122: Complete scalar conversion and shared Tile conversion semantics

## Context

The scalar conversion family has its own type-code namespaces. It does not use
the five-bit Tile `DataType` allocation. PTO incorrectly applied the Tile
floating allocation to scalar destinations and rejected the scalar source
codes for half- and byte-width floating carriers. Exact `fcvt.fs2fh` compiler
output therefore interpreted raw destination code 2 as TF32 truncation instead
of FP16 conversion.

The pto-v0 reference profile also maintained separate scalar and TCVT
conversion paths. The scalar path implemented only finite FP32 and FP64
subsets, while TCVT retained profile placeholders for most overlapping type
pairs. The duplicate paths could disagree for the same source value,
destination type, rounding mode, and saturation selection.

## Decision

The complete scalar conversion encoding is:

- scalar floating codes 0, 1, 2, and 3 select FP64, FP32, FP16, and E4M3;
- FCVT accepts every ordered pair of those four floating codes and reserves
  destination codes 4 through 31;
- FCVTA, FCVTM, FCVTN, FCVTP, and FCVTZ accept every floating source code and
  retain destination codes 0 through 3 for U64/U32/U16/U8 and 4 through 7 for
  S64/S32/S16/S8; destination codes 8 through 31 are reserved;
- SCVTF source codes 0 through 3 select S64/S32/S16/S8, UCVTF source codes 0
  through 3 select U64/U32/U16/U8, and both instructions accept floating
  destination codes 0 through 3 while reserving 4 through 31.

The legacy scalar `.fb` carrier is the E4M3 public type. E5M2, HiF8, and other
eight-bit Tile formats remain separately selected Tile types and are not
aliases of scalar `.fb`.

Scalar conversion and TCVT use one common conversion profile for the twelve
overlapping types: FP64, FP32, FP16, E4M3, S64, S32, S16, S8, U64, U32, U16,
and U8. Scalar instructions supply saturation disabled. TCVT supplies its
resolved RMode and Sat controls. Tile-only formats retain their explicit TCVT
profile rules.

The common profile is deterministic:

- finite floating and integer values are interpreted at the source format,
  rounded once at the destination boundary, and encoded at the destination;
- exact results produce no flags; inexact results produce NX; gradual
  underflow produces UF with NX; finite overflow produces OF with NX;
- saturation clamps finite overflow to the destination finite endpoint;
  without saturation, integer narrowing and finite floating-to-integer range
  overflow retain the low destination-width bits after rounding;
- quiet NaNs convert to the destination canonical NaN without flags;
  signaling NaNs add NV; a NaN converted to integer produces zero with NV;
- infinities remain signed infinities when the floating destination has them;
  a destination without infinity uses its canonical NaN when saturation is
  disabled or its signed finite endpoint when saturation is enabled, with OF
  and NX; infinity converted to integer produces the signed endpoint or the
  unsigned zero/maximum endpoint with NV;
- signed floating zero preserves its sign for floating destinations and
  converts to integer zero exactly.

These rules close the scalar domains of draft ADR 0090 and the TCVT tuples
whose source and destination are both in the shared twelve-type set. Other
TCVT type pairs, quantization, and dequantization remain owned by their current
Tile-specific profile decisions.

## Compatibility

- Opcode, field locations, register selectors, queue behavior, TPC updates,
  and sticky-flag publication do not change.
- FCVT raw destination 2 changes from incorrect TF32 truncation to FP16;
  raw destination 3 selects E4M3, and raw 4 through 14 become reserved.
- Scalar source codes 2 and 3 become accepted FP16 and E4M3 carriers for the
  conversion family only; other scalar floating operations are unchanged.
- SCVTF and UCVTF destinations 4 through 14 become reserved.
- TCVT behavior changes only for the shared twelve-type conversion set and
  continues to use its explicit saturation control.

## Verification obligations

- Exhaustively cover all 16 FCVT, 32 cases per fixed FP-to-integer mnemonic,
  and 16 cases each for SCVTF and UCVTF, plus every reserved destination.
- Cover every source width, signedness, destination width, rounding mode,
  saturation mode, exact result, inexact result, wrap, endpoint, overflow,
  underflow, signed zero, quiet NaN, signaling NaN, and infinity rule.
- Prove scalar and one-element TCVT results and flags are identical for every
  shared type pair and equal control.
- Exact compiler SCVTF/FMADD/FCVT and FCVTZ streams match their independent
  ELF goldens.
- FP16 TLOAD 16x16 and 32x32 cases match independent binary16 goldens.

## Binary envelope consequence

The encoded-form envelope remains exactly 542 forms. No form identity,
instruction length, opcode mask or match, or operand bit position changes.
Only the accepted `SrcType` and `DstType` constraint sets of the eight existing
scalar conversion forms change.

The reviewed encoded-form fingerprint is rebound from
`12f4d52a22df0f8a7e6c90144d57495db7cb58e7cdda3ad32978529db53bc7c1` to
`a862ea5c56df7cbc6c4f2659f9dd4eb3399ab5f4750d53fdd19f8e4a4b67df55`.
The release encoding projection is correspondingly rebound from
`b2615654e077fbb55d08f56dac293da21a8604a330dc4fd9e70ccce55df68b5f` to
`8757aa8561cade0a93fb531280b6884131ef545d06e53877066e922cc45ab43a`.

## Decision state

The architecture owner confirmed the complete scalar conversion matrices,
the E4M3 scalar byte-float binding, and the shared scalar/TCVT conversion
profile on 2026-09-01.
