---
{
  "id": "ADR-NUM-0009",
  "title": "Numeric format value classification",
  "title_zh": "数值格式值分类",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-01",
  "accepted": "2026-08-01",
  "rejected": null,
  "superseded": null,
  "baseline": "f0e564328d3c011c51e62ebe961e70309838b844",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-FMAX-DECISION-BINDING-001",
    "PTO-FMIN-DECISION-BINDING-001",
    "PTO-NUMERIC-FINITE-DECOMPOSITION-001",
    "PTO-NUMERIC-FORMAT-DESCRIPTOR-001",
    "PTO-TMAX-CONTRACT-001",
    "PTO-TMIN-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FORMAT-BF16",
    "PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR",
    "PTO-ARCH-DATA-TYPES-FORMAT-E1M2X2",
    "PTO-ARCH-DATA-TYPES-FORMAT-E2M1X2",
    "PTO-ARCH-DATA-TYPES-FORMAT-E2M3",
    "PTO-ARCH-DATA-TYPES-FORMAT-E3M2",
    "PTO-ARCH-DATA-TYPES-FORMAT-E4M3",
    "PTO-ARCH-DATA-TYPES-FORMAT-E5M2",
    "PTO-ARCH-DATA-TYPES-FORMAT-E8M0",
    "PTO-ARCH-DATA-TYPES-FORMAT-FP16",
    "PTO-ARCH-DATA-TYPES-FORMAT-FP32",
    "PTO-ARCH-DATA-TYPES-FORMAT-FP64",
    "PTO-ARCH-DATA-TYPES-FORMAT-HF32",
    "PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2",
    "PTO-ARCH-DATA-TYPES-FORMAT-HIF8",
    "PTO-ARCH-DATA-TYPES-FORMAT-TF32",
    "PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION",
    "PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS",
    "PTO-SCALAR-FMAX",
    "PTO-SCALAR-FMIN",
    "PTO-SCALAR-MODEL-FSU-PROFILE",
    "PTO-TILE-MODEL-EXECUTION-COMPARISON",
    "PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD",
    "PTO-TILE-MODEL-EXECUTION-UNARY",
    "PTO-TILE-MODEL-NUMERIC-FORMATS",
    "PTO-TILE-MODEL-ORDERING-SORTING",
    "PTO-TILE-TMAX",
    "PTO-TILE-TMIN"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "PD-05-SC1",
    "ADR-0048"
  ]
}
---
# ADR-NUM-0009: Numeric format value classification

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Decision scope

ADR 0043 is the canonical `ADR 0043` binding and availability checkpoint.
This decision is the `ADR 0048` format-classification checkpoint and adds a
narrower executable value-classification contribution to the continuing ADR 0087
work. It does not complete ADR 0087 or ADR 0088 or change the M4 maturity floor.

## Context

ADR 0040 separated the five numeric code namespaces and fixed all 25
`TileDataType` identities, carrier widths, and packed four-bit order. The named
hardware numeric contract already records the bit layout of every type, but the
ASL model had no shared executable definition of zero, subnormal, normal,
infinity, quiet NaN, signaling NaN, or invalid internal encodings for tile
values. The active `pto-v0` profile consequently retained a raw-carrier helper
that deliberately treated every tile value as non-NaN.

That gap blocked later decisions from stating special-value, subnormal,
conversion, reduction, ordering, and matrix rules without repeating or
implicitly guessing format facts.

## Decision

### One typed classification vocabulary

`NumericValueClass` contains exactly these mutually exclusive classes:

- invalid encoding;
- positive and negative zero;
- positive and negative subnormal;
- positive and negative normal;
- positive and negative infinity;
- quiet NaN; and
- signaling NaN.

`TileNumericValueClass(data_type, value)` returns one class for every
`TileDataType` and every ASL `Word` carrier. Bits above the logical element
width are verification-carrier padding and do not participate in the value.

### Internally constrained encodings

Four formats have constraints inside their architectural carrier:

| Type | Required bits |
| --- | --- |
| TF32 | bits 12:0 are zero |
| HF32 | bits 11:0 are zero |
| E3M2 | bits 7:6 are zero |
| E2M3 | bits 7:6 are zero |

`TileNumericEncodingValid` reports these constraints. A violating value is
classified as `NumericValue_InvalidEncoding`. This checkpoint classifies the
bit pattern; it does not yet decide which operation/type/profile tuples may
consume it or which architecture-visible rejection or canonicalization rule a
future profile applies.

### Special-value capabilities

The following table fixes format capabilities independently of instruction
behavior:

| Types | NaN | signaling NaN | infinity | subnormal | signed zero |
| --- | --- | --- | --- | --- | --- |
| FP64, FP32, TF32, HF32, FP16, BF16 | yes | yes | yes | yes | yes |
| HiF8 | yes | no | yes | yes | no |
| E4M3 | yes | no | no | yes | yes |
| E5M2 | yes | yes | yes | yes | yes |
| E3M2, E2M3 | no | no | no | yes | yes |
| E2M1X2, E1M2X2, HiF4X2 | no | no | no | no | yes |
| E8M0 | yes | no | no | no | no zero encoding |
| signed and unsigned integer types | no | no | no | no | no negative zero |

For packed four-bit types, classification applies to one logical low-nibble
value. TLSU packing and sibling preservation remain governed by ADR 0033.

### Canonical NaNs

`TileNumericCanonicalNaN` returns whether a type has a NaN and, when it does,
the exact canonical encoding:

| Type | Canonical NaN |
| --- | --- |
| FP64 | `0x7FF8000000000000` |
| FP32, TF32, HF32 | `0x7FC00000` |
| FP16 | `0x7E00` |
| BF16 | `0x7FC0` |
| HiF8 | `0x80` |
| E4M3 | `0x7F` |
| E5M2 | `0x7E` |
| E8M0 | `0xFF` |

Finite-only and integer types return `available = FALSE`; the accompanying
zero carrier has no numeric meaning and must not be used as a NaN substitute.

### Shared scalar classification

Scalar FP32 and FP64 NaN, signaling-NaN, zero, and canonical-NaN helpers use
the same format classifier. This removes a duplicate definition while
preserving the accepted scalar FSU behavior.

### Profile boundary

This decision does not bind the accepted value classes into the active
`pto-v0` tile arithmetic hooks. `pto-v0` remains the deterministic raw-carrier
reference profile. In particular, `TileProfileValueIsNaN` still returns false
there. A named numeric profile must explicitly use the accepted classifier and
supply complete operation/type result, flag, and rejection rules before it may
claim hardware or IEEE conformance.

## Rejected alternatives

- **Keep classification in each operation hook.** Rejected because duplicate
  bit tests can disagree across compare, conversion, reduction, sort, and
  matrix families.
- **Make `pto-v0` IEEE-aware implicitly.** Rejected because that would change
  the active reference profile without closing its result and flag contracts.
- **Treat all exponent-all-ones formats alike.** Rejected because E4M3 has no
  infinity, E8M0 has one NaN code and no zero, and finite-only types have no
  NaN or infinity.
- **Treat nonzero carrier padding as invalid.** Rejected because bits above the
  logical element width are ASL verification storage, not architectural bits.
- **Accept internally noncanonical TF32, HF32, E3M2, or E2M3 payloads as normal
  values.** Rejected because it erases explicit format constraints and makes
  later legality decisions unreviewable.

## Verification obligations

Executable assertions cover:

- quiet and signaling NaNs for every signaling-capable format;
- both infinities where defined;
- positive and negative zero where defined;
- minimum positive and negative subnormals;
- finite-only and packed four-bit values;
- every internal invalid-encoding constraint;
- E8M0's NaN and absence of zero; and
- canonical-NaN availability and exact bits.

The repository checker binds the ASL classifier, this decision, the hardware
profile, the generated format ledger, and the direct assertions together.

## Remaining boundaries

ADR 0087 still requires the complete operation/type/profile legality matrix,
target support, and result vectors. ADR 0050 now owns the bounded
ADR 0050 hardware special-value checkpoint for produced canonical NaNs,
comparison NaN/signed-zero results, and MIN/MAX NaN/signed-zero results. ADR 0088
still requires infinity arithmetic, broader NaN creation, conversions,
reductions, quantization, matrix results, and complete flag/status behavior.
ADR 0049 owns subnormal execution and tininess rules for the named hardware
profile. ADR 0089 owns scalar exception flags. No variation route or complete
numeric domain is closed by classification alone.

## Affected sources

- `asl/types.asl`
- `asl/numeric/formats.asl`
- `asl/scalar/floating.asl`
- `tests/asl/arch/profile/reference-profile/arch-exec-concrete-001.asl`
- `spec/hardware-conformance-profile.json`
- `spec/evidence/numeric-format-namespace-contract.json`
- `scripts/generate-numeric-format-namespace-contract`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Special-value, conversion, ordering, and matrix decisions require
one bit-exact classifier. Duplicated per-operation tests would disagree on
formats with constrained bits or non-IEEE value classes.

**中文。** 特殊值、转换、排序与矩阵决策需要一个位精确 classifier。逐操作重复判断
会在受约束位或非 IEEE 值类别格式上产生分歧。

### Detailed decision / 详细决策

**English.** One typed vocabulary classifies every Tile value, enforces TF32,
HF32, E3M2, and E2M3 carrier constraints, records each format's special-value
capabilities, and returns exact canonical NaNs where available. Scalar FP32/64
helpers reuse the same classification.

**中文。** 统一 typed 词汇分类每个 Tile 值，强制 TF32、HF32、E3M2、E2M3 carrier
约束，记录各格式特殊值能力，并在可用时返回精确 canonical NaN。Scalar FP32/64
helper 复用同一分类。

### What changed / 改动内容

#### English

- Added executable value classes for all numeric carriers.
- Closed internal encoding validity and special-value capabilities.
- Centralized canonical-NaN and scalar/tile classification.

#### 中文

- 为全部数值 carrier 增加可执行值分类。
- 闭合内部编码有效性与特殊值能力。
- 集中 canonical-NaN 及 scalar/tile 分类。

### Scope and boundaries / 范围与边界

**English.** Classification alone does not make a tuple legal or choose an
operation result, rejection, flag, or profile binding. Those behaviors require
separate accepted rules that consume the classifier for a precisely stated
operation and type.

**中文。** 分类本身不使类型组合合法，也不选择操作结果、拒绝、标志或配置绑定。
