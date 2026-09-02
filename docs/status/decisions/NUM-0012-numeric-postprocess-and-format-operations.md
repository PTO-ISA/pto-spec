---
{
  "id": "ADR-NUM-0012",
  "title": "Numeric post-process and format operations",
  "title_zh": "数值后处理与格式操作",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-21",
  "accepted": "2026-08-21",
  "rejected": null,
  "superseded": null,
  "baseline": "1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f",
  "target_releases": [
    "0.58.1",
    "0.58.2"
  ],
  "affected_ndf": [
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-FP19-PARAMETER-CARRIER-001",
    "PTO-TCVT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FP19",
    "PTO-BLOCK-B-FPATR",
    "PTO-TILE-TCVT"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-GOV-0006"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "legacy_ids": [
    "PRD-174",
    "PRD-175",
    "PRD-176",
    "PRD-177",
    "PRD-178",
    "PRD-179",
    "PRD-180",
    "PRD-181",
    "PRD-182",
    "PRD-183",
    "ADR-0085"
  ]
}
---
# ADR-NUM-0012: Numeric post-process and format operations

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 174: B.FPATR numeric post-processing is bit-exact architecture

Every assigned nonzero `B.FPATR.PreQuantMode`, every assigned `ReluMode`, and
every enabled RowMax or GroupMax result MUST have one bit-exact architectural
result. Identical input encodings, parameters, dimensions, and numeric controls
MUST produce identical destination and auxiliary-output encodings across all
conforming implementations.

The matrix post-processing profile MUST define conversion order, parameter
interpretation, rounding, saturation, overflow, exceptional values, output
packing, activation, and auxiliary-reduction results. A nonzero assigned mode
MUST NOT fall back to an identity transform or an implementation-selected
numeric policy.

## Decision 175: B.FPATR reductions precede destination conversion and activation

Matrix RowMax and GroupMax consume the complete raw accumulator result before
destination conversion or activation. `MaxAbsEn` and `RowMaxInit` affect this
raw-accumulator reduction stage. PreQuant then converts only the primary `D`
result, and the selected ReLU, scalar LReLU/PReLU, or vector PReLU operation
selects the positive or negative path multiplier before the single destination
conversion of each `D` element.

PreQuant and activation do not alter RowMaxOut or GroupMaxOut. Those auxiliary
outputs retain the accumulator data type and format. The processed `D` and all
enabled auxiliary outputs are prepared from the same pre-commit state and
published as one atomic output group.

## Decision 176: B.FPATR activation selects the pre-conversion multiplier

For a nonnegative raw accumulator, the ordinary quantization scale is the
selected multiplier. For a negative raw accumulator, no activation selects
the ordinary quantization scale, `ReluMode=1` selects zero, and scalar or
per-column LReLU/PReLU selects its FP19 activation parameter. The selected
multiplier is applied before the mode's intermediate and destination
conversion; activation never decodes and re-encodes an already rounded
destination value.

The scalar mode obtains one finite nonnegative FP19 parameter from the assigned
dense B.IOR source. The vector mode obtains one such FP19 parameter per
destination column from the assigned `1 x N` Local parameter Tile. An
activation parameter replaces, rather than multiplies, the negative-path
quantization scale. NaN does not participate in an ordered comparison with
zero.

## Decision 177: B.FPATR scalar and vector quantization use multiplicative scales

A scalar-parameter PreQuant mode multiplies every raw accumulator element by
one scalar scale. A vector-parameter mode multiplies each element by the scale
selected by its destination column from the assigned `1 x N` parameter Tile.
No assigned scale mode interprets the parameter as a divisor.

For an integer-output mode whose parameter carrier includes an offset, the
scaled value is rounded and saturated to the assigned S5, S9, or S17
intermediate before adding that signed offset. Final destination encoding then
uses the selected `B.DATR.Sat` clamp/wrap rule. The two S32-to-S16 shift modes
perform the assigned signed arithmetic right shift and saturate the S16 result;
they do not consume a multiplicative scale.

## Decision 178: B.FPATR integer saturation control distinguishes clamp from wrap

After every required intermediate saturation, `B.DATR.Sat=1` clamps the result
to the minimum or maximum representable destination value. `B.DATR.Sat=0`
does not clamp an ordinary finite overflow; it truncates the rounded integer to
the destination element width, producing the corresponding modulo-`2^N`
two's-complement or unsigned encoding.

Fixed shift modes already produce a saturated S16 result and reject an encoded
Sat request. Scalar LReLU/PReLU and vector PReLU participate at the same
pre-conversion intermediate point rather than performing a second destination
encoding.

## Decision 179: B.FPATR PreQuant codes retain one closed source, destination, and parameter table

The assigned `PreQuantMode` table is:

| Code | Mode | Accumulator | Destination | Parameter |
| ---: | --- | --- | --- | --- |
| 0 | NoQuant | FP32, S32, or U32 | unchanged | none |
| 1 | F322F16 | FP32 | FP16 | none |
| 2 | VREQ8 | S32 | S8 | per-column FP19 scale and signed 9-bit offset |
| 3 | REQ8 | S32 | S8 | scalar FP19 scale and signed 9-bit offset |
| 4 | VDEQF16 | S32 | FP16 | per-column FP19 scale |
| 5 | DEQF16 | S32 | FP16 | scalar FP19 scale |
| 12 | VSHIFTS322S16 | S32 | S16 | per-column shift code |
| 13 | SHIFTS322S16 | S32 | S16 | scalar shift code |
| 16 | F322BF16 | FP32 | BF16 | none |
| 17 | REQ4 | S32 | S4X2 | scalar FP19 scale and signed 5-bit offset |
| 18 | VREQ4 | S32 | S4X2 | per-column FP19 scale and signed 5-bit offset |
| 19 | DEQS16 | S32 | S16 | scalar FP19 scale and signed 17-bit offset |
| 20 | VDEQS16 | S32 | S16 | per-column FP19 scale and signed 17-bit offset |
| 23 | VQF322B8_PRE | FP32 | S8 | per-column FP19 scale and signed 9-bit offset |
| 24 | QF322B8_PRE | FP32 | S8 | scalar FP19 scale and signed 9-bit offset |
| 25 | QF322HIF8_PRE | FP32 | HiF8 | scalar FP19 scale |
| 26 | QF322FP8_PRE | FP32 | E4M3 | scalar FP19 scale |
| 27 | QF322F32_PRE | FP32 | FP32 | scalar FP19 scale |
| 28 | VQF322HIF8_PRE | FP32 | HiF8 | per-column FP19 scale |
| 32 | QF322F16_PRE | FP32 | FP16 | scalar FP19 scale |
| 33 | VQF322F16_PRE | FP32 | FP16 | per-column FP19 scale |
| 34 | QF322BF16_PRE | FP32 | BF16 | scalar FP19 scale |
| 35 | QS322BF16_PRE | S32 | BF16 | scalar FP19 scale |
| 36 | VQF322BF16_PRE | FP32 | BF16 | per-column FP19 scale |
| 37 | VQF322FP8_PRE | FP32 | E4M3 | per-column FP19 scale |
| 38 | VQF322F32_PRE | FP32 | FP32 | per-column FP19 scale |
| 39 | VQS322BF16_PRE | S32 | BF16 | per-column FP19 scale |

Every other six-bit value is reserved. A nonzero mode used with a different
accumulator class MUST reject before source snapshots, allocation, numeric
status, or destination effects. The four-bit shift code represents an
arithmetic right shift by one through sixteen bits.

## Decision 180: B.FPATR parameters and special values are canonical

FP19 uses one sign bit, an eight-bit exponent with bias 127, and a ten-bit
fraction. It preserves signed zero and gradual subnormals and assigns IEEE-like
infinity and NaN classes as values, but B.FPATR parameter legality is narrower.
A quantization scale MUST be positive normal. An activation parameter MUST be
positive zero or positive normal. Subnormal, infinite, NaN, negative, or
nonzero-unused-bit carriers reject before effects. Scalar parameters use B.IOR;
vector parameters use one row-major `1 x N` U64 carrier Tile and select the
element for the destination column.

Signed integer offsets are two's-complement values at their assigned 5-, 9-,
or 17-bit width. For float-to-integer special values, `Sat=0` uses the common
destination indefinite encoding and records invalid status. `Sat=1` converts
NaN to zero and clamps positive or negative infinity to the corresponding
destination endpoint; NaN records invalid and infinity records overflow plus
inexact status. With `Sat=1`, floating NaN produces zero; with `Sat=0`, it
produces the destination canonical quiet NaN. A signaling NaN additionally
records invalid status in either case.

Floating finite results preserve subnormals with tininess detected after
rounding. On floating overflow, `Sat=1` returns the largest finite value with
the input sign; `Sat=0` returns signed infinity where the destination format
has infinity, or the canonical quiet NaN for finite-only E4M3. Overflow and
inexact status are recorded.

## Decision 181: B.FPATR output carriers and numeric status publish atomically

FP16, BF16, HiF8, E4M3, FP32, S16, and S8 use their architectural element
encodings. Each S4X2 logical element occupies the low nibble of its model
carrier and adjacent logical elements use the existing packed-memory nibble
order. RowMaxOut and GroupMaxOut retain the raw accumulator data type, use
row-major `M x 1` and `M x ceil(N/GroupN)` shapes, and observe the fixed
increasing-column reduction order.

All post-processing and reduction flags are accumulated before commit. The
processed D payload, enabled auxiliary payloads, descriptors, and sticky
numeric status are published together. A failed preflight, conversion, or
allocation exposes none of them.

## Decision 182: floating and scale formats expose exact finite decompositions

Every assigned floating or scale Tile DataType has one exact descriptor for
its carrier width, logical lane width, lanes per carrier, sign, exponent and
fraction fields, exponent bias, constrained carrier bits, and supported
special-value classes. Integer Tile DataTypes have no floating-format
descriptor.

For every valid finite floating or scale encoding, the formal model returns an
availability flag, sign, integer significand, and integer exponent whose exact
value is `(-1)^sign * UInt(significand) * 2^exponent`. This decomposition uses
only integers and bitvectors and performs no rounding. Invalid internal
encodings, infinities, NaNs, and integer Tile DataTypes return unavailable.

TF32 and HF32 retain their required low-zero carrier constraints. E3M2 and
E2M3 retain their required high-zero carrier constraints. Packed E2M1X2,
E1M2X2, and HiF4X2 decompose one selected four-bit logical lane. E8M0 encodes
`2^(raw-127)` for raw values `0x00..0xFE`; `0xFF` is unavailable NaN, and a
scale block contains 32 logical K elements.

## Decision 183: TCVT to E8M0 rounds a positive base-two exponent

The named hardware profile accepts exactly `FP16`, `BF16`, and `FP32` as
sources when `TCVT` selects an `E8M0` destination. Other sources to E8M0
reject before destination allocation or payload effects. This restriction
does not narrow other TCVT destination types.

For a positive finite source in the inclusive range `2^-127` through `2^127`,
TCVT rounds `log2(source)` to an integer exponent under the resolved `RMode`
and writes `exponent + 127`. Exact powers of two set no status; other in-range
values record inexact. `RNE`, `RTM`, `RTP`, `RTZ`, `RNA`, `RTO`, and `RHB`
retain their architectural meanings in the exponent domain.

Positive finite values below `2^-127` underflow and values above `2^127`
overflow. With `Sat=1` they clamp to `0x00` or `0xFE`; with `Sat=0` they
produce `0xFF`. Underflow or overflow also records inexact. Positive infinity
uses the overflow rule. Positive or negative zero, every negative value, and
every NaN produce `0xFF` and record invalid. `Canonicalize` keeps its existing
private-CUBE-source representation role and does not change this value map.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** The mnemonic audit contained many interdependent numeric rules
for Matrix post-processing and format operations. They need one historical
decision owner so conversion order, parameters, packing, status, and atomic
publication cannot drift independently.

**中文。** Mnemonic 审计包含许多相互依赖的矩阵后处理与格式操作数值规则。它们
需要一个历史决策 owner，避免转换顺序、参数、packing、状态与原子发布各自漂移。

### Detailed decision / 详细决策

**English.** Decisions 174–183 make assigned `B.FPATR` modes bit-exact, order
reductions before conversion/activation, define multipliers, saturation and
packing, close parameter and special-value handling, atomically publish status,
expose finite decompositions, and define the accepted E8M0 conversion path.

**中文。** 决策 174–183 使已分配 `B.FPATR` mode 位精确，规定归约先于转换/激活，
定义 multiplier、saturation、packing、参数与特殊值处理、状态原子发布、有限值
分解及受支持 E8M0 转换路径。

### What changed / 改动内容

#### English

- Closed assigned post-process mode arithmetic and output carriers.
- Fixed reduction, activation, conversion, saturation, and packing order.
- Added atomic status publication and exact format decomposition/E8M0 rules.

#### 中文

- 闭合已分配后处理 mode 算术与输出 carrier。
- 固定归约、激活、转换、饱和与 packing 顺序。
- 增加状态原子发布及精确格式分解/E8M0 规则。

### Scope and boundaries / 范围与边界

**English.** This record preserves accepted audit decisions; current normative
meaning remains in affected ASL/NDF, and unassigned modes remain reserved.

**中文。** 本记录保存已接受审计决策；当前规范含义仍在相关 ASL/NDF 中，未分配
mode 继续保留。
