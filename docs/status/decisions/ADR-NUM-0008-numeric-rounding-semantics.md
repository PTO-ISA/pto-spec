---
{
  "id": "ADR-NUM-0008",
  "title": "Numeric rounding semantics",
  "title_zh": "数值舍入语义",
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
  "baseline": "335323a85ab2d3d2a3aec0d0d93f1ee13c9cd310",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-B-DATR-FIELDS-001",
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-FCVTM-DECISION-BINDING-001",
    "PTO-FCVTN-DECISION-BINDING-001",
    "PTO-FCVTP-DECISION-BINDING-001",
    "PTO-FCVTZ-DECISION-BINDING-001",
    "PTO-TCVT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-ROUNDING",
    "PTO-BLOCK-B-DATR",
    "PTO-SCALAR-FCVT",
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-FCVTM",
    "PTO-SCALAR-FCVTN",
    "PTO-SCALAR-FCVTP",
    "PTO-SCALAR-FCVTZ",
    "PTO-TILE-TCVT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "PD-03",
    "ADR-0047"
  ]
}
---
# ADR-NUM-0008: Numeric rounding semantics

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Decision scope

This decision completes the rounding decision and supersedes the result-open parts of ADR 0039.
ADR 0049 separately closes subnormal handling for the named hardware profile; ADR 0087 and
ADR 0088 through ADR 0095 remain outside this decision.

## Affected domains

- `cube-matrix`
- `scalar-binary`
- `scalar-fp-convert`
- `scalar-fp-to-integer`
- `scalar-fused`
- `scalar-integer-to-fp`
- `scalar-unary`
- `tile-binary`
- `tile-convert`
- `tile-dequantize`
- `tile-expand`
- `tile-fused`
- `tile-partial`
- `tile-quantize`
- `tile-reduction`
- `tile-unary`

## Context

ADR 0039 separated the scalar active-rounding field, fixed scalar conversion
mnemonics, bundle `RMode`, public conversion controls, target controls, and
backend-only controls. It deliberately left their meanings and every
operation-domain rounding point open.

The remaining evidence contains two traps for an implementation:

- the scalar and bundle selectors are both three bits wide but do not share an
  encoding namespace; and
- `FCVTA` means nearest with ties away from zero, not directed rounding away
  from zero for every inexact value.

PTO defines the scalar field location, the four assigned directional codes,
and an RNE fallback for reserved values in the owning ASL.

## Decision

### Semantic modes

The ASL type `NumericRoundingMode` is the common semantic vocabulary:

| Name | Rule |
| --- | --- |
| RNE | nearest, ties to even |
| RTM | toward negative infinity |
| RTP | toward positive infinity |
| RTZ | toward zero |
| RNA | nearest, ties away from zero |
| RTO | if inexact, select the adjacent result whose least-significant retained integer bit is one |
| RHB | nearest; on an exact halfway case select the numerically greater candidate |

Encoded selector namespaces must translate explicitly to this type. Equal bit
widths or ordinals never imply equal meanings.

### Scalar active rounding

`CORE_STATE[39:37]` has four assigned active-rounding encodings:

| Raw value | Resolution |
| --- | --- |
| `000` | RNE |
| `001` | RTM |
| `010` | RTP |
| `011` | RTZ |
| `100`–`111` | reserved; resolve to RNE |

The reserved fallback is deterministic and has no trap or other architectural
effect. It does not import meanings from bundle `RMode`.

Scalar floating binary, unary, format-conversion, and integer-to-floating
operations use the resolved active mode when encoding their destination.
Fused multiply-add variants evaluate the exact fused expression and round once
at the destination boundary.

### Fixed scalar conversions

The conversion mnemonic, not `CORE_STATE.FRM`, selects the mode:

| Mnemonic | Mode |
| --- | --- |
| `FCVTA` | RNA |
| `FCVTM` | RTM |
| `FCVTN` | RNE |
| `FCVTP` | RTP |
| `FCVTZ` | RTZ |

The finite source is rounded once before ADR 0090 selects an out-of-range,
indefinite, or saturation result. This decision fixes the order but leaves
those ADR 0090 results open.

### Bundle and public conversion selectors

`B.DATR.RMode` has the following complete mapping:

| Raw value | Bundle name | Semantic mode |
| --- | --- | --- |
| `000` | NONE | operation-defined default |
| `001` | RNE | RNE |
| `010` | RTZ | RTZ |
| `011` | RDN | RTM |
| `100` | RUP | RTP |
| `101` | RNA | RNA |
| `110` | RTO | RTO |
| `111` | RHB | RHB |

The public conversion enumeration is a separate namespace and translates as
follows:

| Public value | Public name | Bundle selection |
| --- | --- | --- |
| 0 | `CAST_NONE` | NONE |
| 1 | `CAST_RINT` | RNE |
| 2 | `CAST_ROUND` | RNA |
| 3 | `CAST_FLOOR` | RDN |
| 4 | `CAST_CEIL` | RUP |
| 5 | `CAST_TRUNC` | RTZ |
| 6 | `CAST_ODD` | RTO |

Public value 7 is unassigned and rejects before effects. There is no public
RHB ordinal in this version. Backend tokens with similar names remain
non-normative unless another accepted profile decision maps them.

Only `ACCCVT`, `TCVT`, `TQUANT`, and `TDEQUANT` consume
`TileNumericSelection`. NONE resolves to RNE except that floating-to-integer
`TCVT` resolves NONE to RTZ. An explicit bundle code always overrides that
default. These operations round at the destination-format boundary before
saturation. Saturation-disabled range results remain ADR 0090 decisions.

### Operation-fixed domains

All other tile operations ignore bundle `RMode` and use operation-fixed rules:

- floating elementwise, expansion, partial, and PReLU results use RNE at each
  operation-defined destination boundary; exact integer, bitwise, comparison,
  minimum, maximum, broadcast, and selection results do not round;
- reductions visit elements in increasing logical row-major order and round
  every floating sum or product step to the declared accumulator type using
  RNE; minimum, maximum, and argument selection do not round; and
- matrix operations visit K in increasing logical order, perform one
  RNE-rounded fused multiply-add into the declared accumulator per term, and
  apply any post-dot bias with RNE. `ACCCVT` owns the later accumulator
  conversion.

The generated domain ledger records the rule and saturation ordering for all
16 affected rounding domains and 100 affected operations.

## Rejected alternatives

- Treating scalar raw values 4 through 7 as the bundle modes was rejected
  because it conflates distinct architectural namespaces.
- Rejecting reserved scalar values before effects was rejected because PTO
  defines a deterministic RNE fallback.
- Defining `FCVTA` as directed away from zero was rejected because it changes
  non-halfway values and conflicts with the mnemonic's ties-away contract.
- Passing public enumeration ordinals directly into `B.DATR.RMode` was rejected
  because `CAST_ROUND`, `CAST_FLOOR`, `CAST_CEIL`, and `CAST_TRUNC` have
  different ordinals from their bundle encodings.

## Consequences

This decision is complete for selector encodings, tie rules, operation defaults,
rounding points, and rounding-before-saturation order. The ASL carries semantic
rounding values rather than ambiguous raw codes across profile hooks.

This decision does not claim complete numeric results. Format encodings and
legality, special values, flags, overflow and indefinite results,
approximation error, reduction tie behavior, quantization equations, matrix
precision beyond the stated rounding points, and bounded target variation
remain owned by ADR 0087 and ADR 0088 through ADR 0095. ADR 0049 separately
owns subnormal handling for the named hardware profile. Stage 5 therefore
remains in progress.

## Evidence

- `asl/types.asl`
- `asl/scalar/floating.asl`
- `asl/scalar/dispatch.asl`
- `asl/bundle/dispatch.asl`
- `asl/tile/conversion.asl`
- `asl/tile/cube.asl`
- `spec/catalog/tile-operations.json`
- `spec/hardware-conformance-profile.json`
- `spec/evidence/numeric-rounding-selector-contract.json`
- `scripts/generate-numeric-rounding-selector-contract`
- `tests/asl/arch/data-types/rounding/arch-static-rounding-contract-001.asl`
- `tests/asl/scalar/model/dispatch/fsu/scalar-exec-flag-and-rounding-helpers-001.asl`
- `tests/asl/tile/model/numeric/rounding/tile-static-rounding-contract-001.asl`
- `spec/evidence/release-traceability-readiness.json`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Equal selector widths hid different encodings, and `FCVTA` was
liable to be misread. PTO needs one semantic vocabulary plus explicit
translations and operation rounding points.

**中文。** 相同 selector 宽度掩盖了不同编码，`FCVTA` 也容易被误解。PTO 需要
统一语义词汇、显式翻译及逐操作舍入点。

### Detailed decision / 详细决策

**English.** The ADR defines RNE/RTM/RTP/RTZ/RNA/RTO/RHB; maps scalar FRM,
fixed conversions, bundle RMode, and public modes; fixes reserved fallback and
NONE defaults; and states where scalar, fused, conversion, tile, and reduction
operations round relative to saturation.

**中文。** 本 ADR 定义 RNE/RTM/RTP/RTZ/RNA/RTO/RHB，映射 scalar FRM、固定转换、
bundle RMode 与公开 mode，固定保留值 fallback 和 NONE 默认值，并规定 scalar、
fused、conversion、tile 与 reduction 相对 saturation 的舍入点。

### What changed / 改动内容

#### English

- Established one common semantic mode vocabulary.
- Closed all public selector translations and defaults.
- Fixed operation rounding points and fused single-round behavior.

#### 中文

- 建立统一语义 mode 词汇。
- 闭合全部公开 selector 翻译与默认值。
- 固定逐操作舍入点及 fused 单次舍入行为。

### Scope and boundaries / 范围与边界

**English.** Saturation-disabled out-of-range results and unrelated numeric
questions remain owned by their respective decisions. This ADR does not make
unsupported operation/type pairs legal or import similarly named backend
rounding controls.

**中文。** 未启用饱和时的越界结果及无关数值问题仍由各自决策负责。
