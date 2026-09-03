---
{
  "id": "ADR-CUBE-0009",
  "title": "CUBE and matrix operations",
  "title_zh": "CUBE 与矩阵操作",
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
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-DATR-MATRIX-ACC-CONTROL-001",
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-BSTART-TGEMV-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMV-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMV-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-ACC-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TGEMVMX-CONTRACT-001",
    "PTO-BSTART-TMATMUL-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMUL-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMUL-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-ACC-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-BIAS-CONTRACT-001",
    "PTO-BSTART-TMATMULMX-CONTRACT-001",
    "PTO-CUBE-ACCUMULATOR-OUTPUT-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-TGEMV-ACC-CONTRACT-001",
    "PTO-TGEMV-BIAS-CONTRACT-001",
    "PTO-TGEMV-CONTRACT-001",
    "PTO-TGEMV-MX-ACC-CONTRACT-001",
    "PTO-TGEMV-MX-BIAS-CONTRACT-001",
    "PTO-TGEMV-MX-CONTRACT-001",
    "PTO-TMATMUL-ACC-CONTRACT-001",
    "PTO-TMATMUL-BIAS-CONTRACT-001",
    "PTO-TMATMUL-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-BIAS-CONTRACT-001",
    "PTO-TMATMUL-MX-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-BSTART-TGEMV",
    "PTO-BLOCK-BSTART-TGEMV-ACC",
    "PTO-BLOCK-BSTART-TGEMV-BIAS",
    "PTO-BLOCK-BSTART-TGEMVMX",
    "PTO-BLOCK-BSTART-TGEMVMX-ACC",
    "PTO-BLOCK-BSTART-TGEMVMX-BIAS",
    "PTO-BLOCK-BSTART-TMATMUL",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-TILE-TGEMV",
    "PTO-TILE-TGEMV-ACC",
    "PTO-TILE-TGEMV-BIAS",
    "PTO-TILE-TGEMV-MX",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-TGEMV-MX-BIAS",
    "PTO-TILE-TMATMUL",
    "PTO-TILE-TMATMUL-ACC",
    "PTO-TILE-TMATMUL-BIAS",
    "PTO-TILE-TMATMUL-MX",
    "PTO-TILE-TMATMUL-MX-ACC",
    "PTO-TILE-TMATMUL-MX-BIAS",
    "PTO-TILE-MODEL-EXECUTION-CUBE",
    "PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-GOV-0006"
  ],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "not-required",
  "amendments": [
    {
      "date": "2026-09-04",
      "baseline": "5f1cb735aa00ad061ec77c691f6a913711316f92",
      "approvers": [
        "Kevin Zhou <zhoubot@gmail.com>"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/234#issuecomment-5529151834",
      "affected_ndf": [
        "PTO-B-DATR-MATRIX-ACC-CONTROL-001",
        "PTO-CUBE-ACCUMULATOR-OUTPUT-001"
      ],
      "affected_units": [
        "PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING",
        "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
        "PTO-TILE-MODEL-EXECUTION-CUBE",
        "PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR"
      ]
    }
  ],
  "legacy_ids": [
    "PRD-049",
    "PRD-050",
    "PRD-051",
    "PRD-052",
    "PRD-053",
    "PRD-054",
    "PRD-055",
    "ADR-0079"
  ]
}
---
# ADR-CUBE-0009: CUBE and matrix operations

## Context

ADR 0062 recorded a single repository-wide mnemonic audit. This record preserves the accepted decisions for this family as one decision-scoped owner. The former identifiers remain only in `legacy_ids` and the generated ADR index; current normative meaning is owned by the affected ASL/NDF clauses.

## Decisions

## Decision 049: `TMATMUL` dimensions are `M`, `N`, and `K` in LB order

`BSTART.TMATMUL` uses `LB0=M`, `LB1=N`, and `LB2=K`. Omission of any one of
these fields supplies the value one for that field. An explicitly encoded or
otherwise resolved value of zero is illegal. Each of `M`, `N`, and `K` MUST
be a nonzero power of two.

The left source has valid shape `M x K`, the right source has valid shape
`K x N`, and the destination has valid shape `M x N`. Each physical Tile row
and column extent MUST be a power of two, and the physical extent MUST contain
the complete valid rectangle. Shape, capacity, and compatibility checks MUST
complete before destination allocation or any other effect.

## Decision 050: `TMATMUL` supports mixed same-class input types and fixed accumulator classes

The `BSTART.TMATMUL` DataType selects the left source type. An optional
`B.DATR.DataType` selects the right source type; if that field is absent, the
right source type defaults to the left source type. Absence is distinct from
an explicitly encoded zero, because encoded DataType zero denotes `FP64`,
which is not supported by `TMATMUL`. The block schema MUST therefore preserve
field presence when applying this default.

The supported floating input set is `FP32`, `TF32`, `HF32`, `FP16`, `BF16`,
`HiF8`, `E4M3`, `E5M2`, `E3M2`, `E2M3`, `E2M1X2`, and `E1M2X2`. The supported
signed input set is `S16`, `S8`, and `S4X2`. The supported unsigned input set
is `U16`, `U8`, and `U4X2`. The two inputs MAY use different types within the
same floating, signed, or unsigned class. A cross-class pair is illegal.

`FP64`, `E8M0`, `HiF4X2`, `S64`, `S32`, `U64`, `U32`, every globally reserved
DataType encoding, and every other type not listed above are reserved or
unsupported for ordinary `TMATMUL` and MUST be rejected before effects.

A floating pair produces an `FP32` accumulator result, a signed pair produces
an `S32` accumulator result, and an unsigned pair produces a `U32` accumulator
result. This result uses the private CUBE output representation. `TCVT`, not
`TMATMUL`, performs conversion to a canonical public representation. A numeric
profile MAY define format-specific arithmetic details, but it MUST preserve
these operand classes, accumulator classes, and encoded numeric controls.

## Decision 051: `TMATMUL` binding, participation, and supplementary fields are closed

The Local form binds a left Local source, a right Local source, and an explicit
new Local destination. The Shared forms bind either a Local left source plus a
Shared right source, or a Shared left source plus a Shared right source; the
destination remains an explicit new Local allocation. `B.IOS` is source-only
for `TMATMUL` and reads only fully published Shared values.

`PE_MASK=0000` is a strict no-op before descriptor access, readiness checks,
allocation, lifetime consumption, faults, or effects. Every executing Local or
Shared binding MUST use `PE_MASK=1111`; a nonzero partial mask is illegal before
effects. All source payloads are snapshotted after complete preflight and before
destination allocation or commit, so source-destination aliasing observes the
old source values and the destination becomes visible only as one complete
result.

`TMATMUL` does not consume mathematical `B.IOR` operands. Its `B.DATR` fields
are closed to `DataType`, `RMode`, and `Sat`. An omitted `DataType` applies the
right-type default in Decision 050 in ADR-CUBE-0009, omitted `RMode` selects `RNE`, and omitted `Sat`
selects disabled saturation. `Layout`, `CMode`, `PadValueOrByteId`, and
`Canonicalize` MUST be zero. The private CUBE result remains noncanonical until
an explicit `TCVT` operation.

The earlier statement that `TMATMUL` did not consume `B.FPATR` is superseded
by ADR 0064. Every Matrix CUBE bundle contains exactly one `B.FPATR`; its
all-zero form selects no post-processing, and nonzero modes determine the
additional scalar, Local source, and Local destination schema.

## Decision 052: `TMATMUL.BIAS` adds one `1 x N` right-side broadcast source

`BSTART.TMATMUL.BIAS` inherits the complete dimension, input-type, accumulator,
binding, participation, supplementary-field, preflight, and commit contract of
`BSTART.TMATMUL`. It adds one Bias source after the left and right matrix
sources.

The Bias source valid shape MUST be exactly `1 x N`, its layout MUST be
row-major, and its DataType MUST equal the result accumulator class selected by
Decision 050 in ADR-CUBE-0009: `FP32`, `S32`, or `U32`. Its payload uses the same private CUBE result
representation as that accumulator class. For every output row `i` and column
`j`, `Bias[0,j]` is added once to the complete dot product for output `D[i,j]`.
No row broadcast, scalar broadcast, full-matrix Bias, or Bias addition inside
the K reduction is defined.

Bias remains a Local source in both the all-Local and Shared-matrix forms.
Shared bindings MAY supply the right matrix or both matrix operands exactly as
defined for `TMATMUL`; they do not bind the Bias or destination. The complete
matrix and Bias sources are snapshotted after preflight, and the explicit new
Local destination becomes visible only as one complete result.

## Decision 053: `TMATMUL.ACC` uses explicit Local accumulator input and destination

`BSTART.TMATMUL.ACC` inherits the complete dimension, matrix input-type,
accumulator-class, binding, participation, supplementary-field, preflight, and
commit contract of `BSTART.TMATMUL`. It adds one explicit Local accumulator
source `C` before the left and right matrix sources and writes one explicit new
Local destination `D`.

`C` MUST have valid shape `M x N`, the same row-major layout and physical
capacity as `D`, and the same private CUBE accumulator representation and
DataType as the result: `FP32`, `S32`, or `U32`. The result is
`D = C + A x B`, with the encoded `RMode` and `Sat` controls applied according
to the selected numeric profile. There is no implicit ACC operand or implicit
destination.

The operation snapshots `C`, `A`, and `B` after complete preflight and before
writing `D`. `C` and `D` MAY resolve to the same Local Tile; this case has
read-old/write-new behavior and becomes visible only as one complete result.
In Shared-matrix forms, Shared bindings MAY supply the right matrix or both
matrix operands, but `C` and `D` remain explicit Local bindings.

## Decision 054: `TMATMULMX` scales each matrix side independently

`BSTART.TMATMULMX` inherits `TMATMUL` dimension ordering, matrix and destination
shapes, explicit Local destination, Core4 participation, private `FP32` result,
numeric controls, preflight, snapshot, and atomic commit rules. Its matrix
inputs are floating only. Each side independently uses one of `FP16`, `BF16`,
`E4M3`, `E5M2`, `E2M1X2`, or `E1M2X2`; the two sides MAY use different listed
types. Every other type, including `HiF4X2`, is unsupported or reserved for
this opcode and MUST reject before effects.

An `FP16` or `BF16` side is not microscaled and MUST omit its scale source. An
`E4M3`, `E5M2`, `E2M1X2`, or `E1M2X2` side is microscaled and MUST provide one
`E8M0` scale source. Providing a scale for an unscaled side or omitting a scale
for a scaled side is illegal. Consequently the canonical source sequence is
left matrix, optional left scale, right matrix, optional right scale, followed
by the explicit new Local destination; matrix DataTypes determine the sequence
unambiguously.

For a scaled left matrix, the scale valid shape is
`M x ceil(K / 32)`. For a scaled right matrix, it is
`ceil(K / 32) x N`. Scale Tiles use row-major layout, their physical row and
column extents are powers of two containing the complete valid shape, and each
E8M0 element applies to the corresponding group of at most 32 K-dimension
matrix elements. An unscaled side behaves as if every scale factor were the
multiplicative identity; no implicit or materialized scale Tile exists.

Shared bindings remain source-only. They MAY supply the right matrix and its
required scale, or both matrices and whichever scales their DataTypes require.
An omitted scale has no Shared binding slot. The destination is always a new
Local `FP32` private CUBE result, and `TCVT` remains the canonical conversion
boundary.

## Decision 055: `TGEMV` is the Local-only `TMATMUL` specialization with `M=1`

`BSTART.TGEMV` is exactly the ordinary `TMATMUL` contract specialized to
`M=1`. `LB0` is therefore fixed to one; canonical assembly omits it, while an
explicit `LB0` is legal only when it resolves to one. `LB1=N` and `LB2=K`,
with the ordinary omission default one and nonzero power-of-two requirement.

The left source is a row vector with valid shape `1 x K`, the right source is
a matrix with valid shape `K x N`, and the explicit new Local destination has
valid shape `1 x N`. The vector and destination use row-major layout; the
right source follows the ordinary matrix layout and physical-capacity rules.
DataType selection, mixed same-class operands, `FP32`/`S32`/`U32` private
result classes, `B.DATR` controls and defaults, full Core4 participation,
preflight, snapshots, and commit are otherwise unchanged from `TMATMUL`.

`TGEMV` is Local-only. `B.IOS` is illegal and no Shared operand form is
defined. `PE_MASK=0000` is the strict no-op; every executing Local binding uses
`1111`. The canonical binding sequence is the `1 x K` vector, the `K x N`
matrix, and the explicit new `1 x N` Local destination.

## 2026-09-04 amendment: raw-partial output and transparent InternalAcc hints

ADR-CUBE-0018 assigns matrix CCTRL without replacing explicit TileReg C or D.
For all ACC forms, C remains the validated architectural accumulator input. For
all successful forms, D remains a newly allocated and atomically published
architectural destination. CCTRL[1] is a non-binding cache-use or prefetch hint
for explicit C and is reserved-zero on init=1 forms. CCTRL[0] selects raw
accumulator-type D output and may hint transparent-cache replacement with the
identical published result; zero retains final post-processing. Cache state and
hint handling cannot change results, faults, allocation, publication, source
lifetime, or ordering.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** A repository-wide mnemonic audit left Matrix decisions dispersed.
This record gives the CUBE family one decision-scoped historical owner so that
dimensions, types, bindings, and variants can be reviewed together.

**中文。** 全仓 mnemonic 审计使矩阵决策分散。本记录为 CUBE 指令族建立一个决策
范围明确的历史 owner，使维度、类型、绑定与变体可以统一审查。

### Detailed decision / 详细决策

**English.** Decisions 049–055 close TMATMUL M/N/K, same-class mixed inputs,
accumulator classes, binding and participation, Bias, explicit ACC, independent
MX scales, and Local-only TGEMV. Later ADRs supersede only the clauses they
explicitly name; current meaning remains in affected ASL/NDF owners.

**中文。** 决策 049–055 闭合 TMATMUL 的 M/N/K、同类混合输入、累加器类别、绑定
与参与、Bias、显式 ACC、独立 MX scale 及仅 Local 的 TGEMV。后续 ADR 仅替代其
明确点名的条款；当前语义仍由相关 ASL/NDF owner 持有。

### What changed / 改动内容

#### English

- Collected seven accepted Matrix audit decisions under one family record.
- Fixed operand classes, defaults, shapes, bindings, and result classes.
- Recorded targeted supersession without replacing current normative owners.

#### 中文

- 将七项已接受矩阵审计决策归入一个指令族记录。
- 固定操作数类别、默认值、shape、绑定与结果类别。
- 记录定向替代关系，但不取代当前规范 owner。

### Scope and boundaries / 范围与边界

**English.** This historical consolidation does not itself change encodings or
authorize behavior beyond the individual decisions and their later amendments.

**中文。** 此历史整合本身不改变编码，也不授权逐项决策及后续修订之外的行为。
