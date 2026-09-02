---
{
  "id": "ADR-CUBE-0006",
  "title": "Local CUBE Matrix Operand Contract",
  "title_zh": "Local CUBE 矩阵操作数契约",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-20",
  "accepted": "2026-08-20",
  "rejected": null,
  "superseded": null,
  "baseline": "328ab1989572b93d5ef5b1e2b726e906b30cbb3c",
  "target_releases": [
    "0.58.3"
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
    "PTO-CUBE-CELL-STATE-001",
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
    "PTO-TILE-MODEL-SHAPE-CUBE-CELL",
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
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/104",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0071"
  ]
}
---
# ADR-CUBE-0006: Local CUBE Matrix Operand Contract

- Issue: [#104](https://github.com/PTO-ISA/pto-spec/issues/104)
- Umbrella: [#72](https://github.com/PTO-ISA/pto-spec/pull/72)
- Baseline: `328ab1989572b93d5ef5b1e2b726e906b30cbb3c`
- Requirement: `PTO-CUBE-LOCAL-MATRIX-001`
- Depends on: accepted `PTO-CUBE-CELL-STATE-001` and
  `PTO-CUBE-CELL-TRANSPORT-001`

## Decision

Local primary operands of the CUBE Matrix family must use persistent CUBE
layouts:

- A uses `CUBE_M16` or `CUBE_M32` and has logical shape M x K;
- B uses `CUBE_N8` and has logical shape K x N;
- C, when present, uses the same M layout class as A and has shape M x N; and
- D uses the same M layout class as A and has shape M x N.

The ordinary Local primary-operand Matrix path is removed. An ordinary Local A,
B, C, or D is illegal before source snapshots or destination allocation.
Ordinary Shared primary inputs are owned by the cooperative Shared decision.

## Dimensions and layout compatibility

LB0=M, LB1=N, and LB2=K are positive logical dimensions independent of per-PE
`TSize`. They are not required to be powers of two.

`CUBE_M16` accepts `1 <= M <= 16`; `CUBE_M32` accepts `1 <= M <= 32`. When
`M <= 16`, either layout class is legal if A, C, D, dtype, derived geometry,
and capacity agree. N and K may span multiple CELLs and are bounded by the
operand descriptors, selected TSize, and architectural model limits rather
than by one-CELL dimensions.

For every primary operand:

- the descriptor layout and dtype-specific CELL geometry must be legal;
- valid dimensions must match the resolved M/N/K roles exactly;
- every valid source element must be defined;
- required bytes must fit the operand's allocation; and
- no valid access may alias CELL padding as an operand.

## Ordinary auxiliary Tiles

Bias and MX scale operands remain ordinary Local Tiles. They retain their
operation-owned dtype, shape, layout, definedness, and alias rules and are not
repacked into a CUBE layout.

Bias is exactly one row-major 1 x N accumulator-type source. MX scales retain
their E8M0 row-major shapes derived independently for A and B. Supplying an
ordinary auxiliary Tile does not make an ordinary primary Tile legal.

## TGEMV

TGEMV remains a Local-only M=1 specialization of the corresponding Matrix
family operation. Its matrix/vector primary inputs use the same CUBE layout
classes: the M-side operand uses M16 or M32 with valid M=1 and the N-side
operand uses N8. Shared TGEMV is not introduced.

## Preflight and faults

Complete operation, dimension, layout, dtype, shape, capacity, definedness,
binding, and auxiliary-Tile legality precedes source snapshots, destination
allocation, payload computation, or lifetime effects. A recognized Matrix
operation with an illegal tuple raises Tile legality and preserves every
descriptor, payload, and source.

## Defaults and protected behavior

- Each omitted dimension retains its existing independent default of one when
  that operation permits omission.
- No omitted command or descriptor field infers a CUBE layout.
- Existing Matrix start function numbers and instruction encodings are
  unchanged.
- Operation-specific input dtype pairs, accumulator types, Bias rules, MX scale
  requirements, and PostProcess mode legality remain independently enforced.
- Zero PE mask precedence remains a strict no-op before active shape checks.

## Explicit exclusions

This decision does not own Shared rendezvous, transpose encoding, partial PE
masks, accumulator C/D identity, or atomic PostProcess output publication.

## Acceptance criteria

The accepted ASL, generated documentation, and independent decoded tests prove:

1. mandatory M16/M32 A/C/D and N8 B roles;
2. ordinary Local primary-operand rejection;
3. M16 and M32 acceptance overlap for M<=16 and M32 acceptance above 16;
4. arbitrary positive M/N/K, N>8, and multi-CELL K/N tails;
5. exact per-PE TSize capacity boundaries and padding exclusion;
6. ordinary Bias and optional MX scale behavior;
7. Local-only TGEMV with M=1;
8. dtype/layout/shape/definedness failures before effects; and
9. unchanged Matrix instruction encodings.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Once Local CUBE layouts are architectural state, Matrix primary
operands need fixed layout roles. Allowing ordinary and CUBE primaries would
create two incompatible representations and ambiguous checks.

**中文。** 当 Local CUBE 布局成为架构状态后，矩阵主操作数必须具有固定布局角色。
同时允许普通与 CUBE 主操作数会产生两种不兼容表示和歧义检查。

### Detailed decision / 详细决策

**English.** A/C/D use one M16 or M32 class and B uses N8; valid shapes exactly
match M/N/K. Ordinary Local primaries reject before effects, while Bias and MX
scales remain ordinary auxiliaries. TGEMV follows the same roles with M=1.

**中文。** A/C/D 使用同一个 M16 或 M32 类，B 使用 N8；有效 shape 精确匹配
M/N/K。普通 Local 主操作数在副作用前拒绝，Bias 与 MX scale 仍为普通辅助项；
TGEMV 沿用相同角色并固定 M=1。

### What changed / 改动内容

#### English

- Made CUBE layouts mandatory for Local Matrix primaries.
- Closed layout, dimension, capacity, padding, and definedness preflight.
- Kept ordinary auxiliary Tiles and existing encodings unchanged.

#### 中文

- 强制 Local 矩阵主操作数使用 CUBE 布局。
- 闭合布局、维度、容量、padding 与 definedness 预检。
- 保持普通辅助 Tile 与既有编码不变。

### Scope and boundaries / 范围与边界

**English.** Shared rendezvous, transpose, masks, C/D identity, and atomic
post-process publication are owned by other decisions.

**中文。** Shared rendezvous、转置、mask、C/D 标识及后处理原子发布由其他决策负责。
