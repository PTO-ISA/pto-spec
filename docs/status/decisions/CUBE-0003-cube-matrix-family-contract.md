---
{
  "id": "ADR-CUBE-0003",
  "title": "CUBE Matrix Family Contract",
  "title_zh": "CUBE 矩阵指令族契约",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-14",
  "accepted": "2026-08-14",
  "rejected": null,
  "superseded": null,
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1"
  ],
  "affected_ndf": [
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
    "PTO-CUBE-LOCAL-MATRIX-001",
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
    "PTO-TILE-MODEL-LEGALITY-MATRIX-CUBE-PRIMARY",
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
    "PTO-TILE-TMATMUL-MX-BIAS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0065"
  ]
}
---
# ADR-CUBE-0003: CUBE Matrix Family Contract

- **Date**: 2026-08-14
- **Deciders**: PTO ISA maintainers

## Decision

The twelve CUBE Matrix block operations form one closed architectural family:

| Function | Block mnemonic | Mathematical result |
| ---: | --- | --- |
| `0` | `BSTART.TMATMUL` | `D = A x B` |
| `1` | `BSTART.TMATMUL.BIAS` | `D = A x B + Bias` |
| `2` | `BSTART.TMATMUL.ACC` | `D = C + A x B` |
| `4` | `BSTART.TMATMULMX` | independently scaled `D = A x B` |
| `5` | `BSTART.TMATMULMX.BIAS` | independently scaled `D = A x B + Bias` |
| `6` | `BSTART.TMATMULMX.ACC` | independently scaled `D = C + A x B` |
| `16` | `BSTART.TGEMV` | `M=1` specialization of function `0` |
| `17` | `BSTART.TGEMV.BIAS` | `M=1` specialization of function `1` |
| `18` | `BSTART.TGEMV.ACC` | `M=1` specialization of function `2` |
| `20` | `BSTART.TGEMVMX` | `M=1` specialization of function `4` |
| `21` | `BSTART.TGEMVMX.BIAS` | `M=1` specialization of function `5` |
| `22` | `BSTART.TGEMVMX.ACC` | `M=1` specialization of function `6` |

`LB0=M`, `LB1=N`, and `LB2=K`.  Each omitted dimension defaults
independently to one; a present zero is illegal; every resolved value is a
power of two.  `TGEMV` fixes `M=1`, permits an explicit `LB0` only when its
resolved value is one, and is Local-only.  The left operand is `M x K`, the
right operand is `K x N`, and the result and explicit accumulator are
`M x N`.  Bias is exactly one Local row-major `1 x N` private-accumulator
source and is added after the complete K reduction.

Ordinary operations accept the exact floating, signed, and unsigned input
sets defined by the Matrix legality owner.  The two input types may differ
only within one class.  Floating, signed, and unsigned pairs produce private
`FP32`, `S32`, and `U32` accumulator results respectively.  ACC forms read an
explicit Local `C` before publishing an explicit newly allocated Local `D`;
`C` and `D` may name the same architectural Tile with read-old/write-new
behavior.

MX operations accept each matrix side independently as `FP16`, `BF16`,
`E4M3`, `E5M2`, `E2M1X2`, or `E1M2X2`.  `FP16` and `BF16` omit a scale.
Every other accepted MX type requires one row-major `E8M0` scale: left scale
shape `M x ceil(K/32)` and right scale shape `ceil(K/32) x N`.  The Local or
Shared mathematical source stream is therefore decoded from the two matrix
types rather than from one fixed arity.  Supplying a scale for an unscaled
side or omitting a required scale is illegal before effects.  `HiF4X2` is not
accepted by a CUBE Matrix operation.

Every Matrix bundle contains exactly one `B.FPATR`.  Its all-zero value selects
no post-processing.  Nonzero modes append their scalar and Local operands
after the mathematical source stream and append destinations after `D` in the
order defined by the complete-bundle post-processing schema.  Missing,
duplicate, malformed, or non-Matrix `B.FPATR` use rejects before allocation or
payload effects.  `B.DATR` supplies only the optional right input type and the
accepted rounding and saturation controls; every other field is zero.

`PE_MASK=0000` is a strict no-op before descriptor reads, Shared readiness,
allocation, faults, or lifetime effects.  Every executing binding uses
`PE_MASK=1111`.  TMATMUL forms may source the right operand, or both matrix
operands, from published Shared Tiles; their Local-only bias, accumulator,
post-process sources, and destinations remain Local.  TGEMV forms reject every
Shared binding.

All schema, dimension, type, shape, layout, capacity, definedness, Shared
readiness, alias, and output-allocation checks complete before source
snapshots.  Mathematical and post-process sources persist after successful
execution.  The complete output group is published atomically; any rejection
or fault leaves descriptors, payloads, allocation state, and source lifetime
unchanged.

## Consequences

The Matrix family uses one readable preflight and execution model while each
mnemonic retains its own instruction ASL page, NDF contract, documentation
page, and independent tests.  Function numbers and encodings are unchanged.
The formal definition, generated catalog, documentation, and tests must derive
their operation-specific type and operand schema from this contract rather
than from a fixed generic Matrix arity.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** The twelve Matrix functions share dimensions, operand roles,
preflight, and commit behavior but differ in bias, accumulator, MX scaling,
and GEMV specialization. A family contract prevents mnemonic-specific drift.

**中文。** 十二个矩阵 Function 共享维度、操作数角色、预检与提交行为，但在
Bias、ACC、MX scale 和 GEMV 特化上不同。统一指令族契约可防止逐 mnemonic 漂移。

### Detailed decision / 详细决策

**English.** The record closes function numbers, M/N/K roles, operand schemas,
type and accumulator classes, scale presence, attribute roles, Shared
restrictions, zero-mask precedence, preflight, source persistence, and atomic
publication. Per-operation ASL and NDF owners specialize this common contract.

**中文。** 本记录闭合 Function 编号、M/N/K 角色、操作数 schema、类型与累加器
类别、scale 是否存在、属性职责、Shared 限制、零 mask 优先级、预检、源持久性
及原子发布。逐操作 ASL 与 NDF owner 在公共契约上特化。

### What changed / 改动内容

#### English

- Consolidated twelve operations into one closed Matrix family.
- Made MX scale and post-process operand ordering derivable.
- Unified pre-effect rejection and complete-output commit behavior.

#### 中文

- 将十二个操作整合为一个闭合矩阵指令族。
- 使 MX scale 与后处理操作数顺序能够确定推导。
- 统一副作用前拒绝与完整输出提交行为。

### Scope and boundaries / 范围与边界

**English.** This ADR does not replace per-mnemonic encodings, NDF clauses,
ASL handlers, or tests, and it licenses no unlisted type or binding.

**中文。** 本 ADR 不取代逐 mnemonic 编码、NDF 条款、ASL handler 或测试，也不
授权未列出的类型或绑定。
