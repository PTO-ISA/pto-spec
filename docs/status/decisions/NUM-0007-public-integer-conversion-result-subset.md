---
{
  "id": "ADR-NUM-0007",
  "title": "Public integer conversion result subset",
  "title_zh": "公开整数转换结果子集",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-TCVT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-TILE-TCVT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0044"
  ]
}
---
# ADR-NUM-0007: Public integer conversion result subset

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Decision scope

Same-width signedness changes, profile support, floating conversion, rounding,
saturation, flags, and exceptional results remain open.

## Context

The public PTO type system defines integer widening and narrowing independently
of any backend. Widening sign-extends a signed source and zero-extends an
unsigned source. Narrowing truncates the high source bits. The public type table
also fixes the signedness and width of `i8/u8/i16/u16/i32/u32/i64/u64`, and
identifies `pto.tcvt` as the tile conversion operation.

The existing ASL integer path normalized only to the destination type. That is
correct for truncation, but not for signed widening: an `S8` payload `0x80`
could become positive `128` in `S16` instead of negative `-128`.

## Decision

For `TCVT`, when both operands use one of the eight public integer types and
their widths differ:

1. Interpret the source payload at the source width.
2. On widening, sign-extend a signed source and zero-extend an unsigned source.
3. On narrowing, retain the low destination-width bits and discard all higher
   bits.
4. Canonicalize the destination payload to PTO's 64-bit model word using the
   destination signedness.

The rule defines 48 ordered unequal-width source/destination tuples: 24
widening and 24 narrowing. It defines results only after a target profile has
accepted the type pair. It does not make any pair supported by A2/A3 or A5.

Same-width conversions are excluded from this bounded decision. Floating-
point, float/integer, quantization, rounding, saturation, exception, and flag
behavior remain behind their existing numeric profile hooks.

## Consequences

`TileConvertValue` now normalizes the source before the destination. Direct and
decoded `TCVT` therefore agree for signed widening, unsigned widening, and
narrowing corners without changing any floating path.

`S5-T2-A6` closes this 48-tuple portable result subset. It does not accept the
parent `ADR 0090` decision, complete the `tile-convert` domain, select any of the
99 broad variation-point routes, or change the M4 maturity floor.

## Evidence

- `spec/evidence/public-integer-conversion-contract.json`
- `scripts/generate-public-integer-conversion-contract`
- `asl/tile/conversion.asl`
- `tests/asl/tile/model/numeric/formats/tile-exec-conversion-001.asl`
- `spec/evidence/public-numeric-type-baseline.json`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/evidence/executable-model-comparison.json`
- `scripts/check-catalogs`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Destination-only normalization handled truncation but lost signed
source meaning during widening. Public integer conversions need a backend-
independent bit rule.

**中文。** 只按目标归一化能够处理截断，却会在 widening 时丢失有符号源含义。公开
整数转换需要独立于 backend 的位级规则。

### Detailed decision / 详细决策

**English.** For unequal-width public integer TCVT tuples, widening sign-
extends signed sources and zero-extends unsigned sources; narrowing retains low
destination bits. The final model word canonicalizes according to destination
signedness, conditional on separate support of the pair.

**中文。** 对不等宽公开整数 TCVT 组合，widening 对有符号源 sign-extend，对无符号
源 zero-extend；narrowing 保留目标宽度低位。最终 model word 按目标 signedness
canonicalize，前提是该类型对另行被支持。

### What changed / 改动内容

#### English

- Closed 48 unequal-width ordered integer conversion results.
- Corrected signed widening and fixed low-bit narrowing.
- Separated result definition from target support.

#### 中文

- 闭合 48 个不等宽有序整数转换结果。
- 修正有符号 widening 并固定低位 narrowing。
- 将结果定义与目标支持分离。

### Scope and boundaries / 范围与边界

**English.** Same-width, floating, quantization, rounding, saturation, and flag
behavior remain outside this bounded subset. Target support for each unequal-
width pair is also a separate prerequisite and is not created by the result
rule.

**中文。** 等宽、浮点、量化、舍入、饱和与标志行为不在此有界子集范围。
