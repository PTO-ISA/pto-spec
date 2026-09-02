---
{
  "id": "ADR-TILE-0005",
  "title": "CUBE raw-carrier totality and composite preflight",
  "title_zh": "CUBE 原始载体完备性与组合预检",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-30",
  "accepted": "2026-07-30",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
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
    "ADR-0034"
  ]
}
---
# ADR-TILE-0005: CUBE raw-carrier totality and composite preflight

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

- Date: 2026-07-30
- Requirements: PTO-REQ-CUBE-001, PTO-REQ-TILE-LEGALITY-001,
  PTO-REQ-PROFILE-001

## Context

PTO accepts 13 direct CUBE functions covering matrix multiply, bias,
accumulation, MX row/column scaling, accumulator conversion, and the analogous
matrix-vector forms. The model had executable helpers, but Stage 4 lacked a
complete type/layout rule, decoded effect evidence for every selector, and a
single preflight boundary for composite operations.

The numeric hooks intentionally receive source and destination type metadata.
Their hardware-accurate floating, saturation, rounding, accumulation-width,
and exceptional-value behavior is a conformance obligation, not something the
portable reference can infer from raw 64-bit payload carriers.

## Decision

### PTO-v0 type and placement rule

PTO-v0 accepts all 25 architectural `TileDataType` values for every CUBE
operand and permits mixed source, scale, bias, accumulator, and destination
types. The reference profile passes raw XLEN carriers and all operand types to
the named matrix profile hooks. This defines deterministic reference behavior
without claiming target numeric equivalence; target-specific numeric results
remain open under `S5-T2`.

Row-major and column-major descriptors may be mixed because CUBE indexes
logical rows and columns through each operand's descriptor. Vector, Matrix,
Memory, and Any locations do not change PTO-v0 semantics. As for every generic
tile operation, an implementation-defined layout rejects before effects.

### Shape and definedness

Matrix multiply requires left columns to equal right rows and requires the
destination valid shape to be exactly left rows by right columns. GEMV adds a
single-column vector requirement. Bias accepts scalar, row, column, or full
destination broadcast shape. MX row scale is destination-rows by one and
column scale is one by destination-columns.

Every source, bias, and scale valid region must be defined before execution.
Accumulating forms additionally require a defined destination. ACCCVT requires
a defined source and matching configured and valid row/column extents. ACCCVT
uses logical coordinates and therefore does not require source and destination
layouts or element types to match.

### Composite preflight and aliases

Decoded legality validates every descriptor, source-definedness rule, shape,
layout, and accumulate precondition before the first destination write. A
failure reports `TILE_LEGALITY` and preserves the complete destination.

Source payloads are snapshotted before destination writes. Bias and scale
descriptors and payloads are also snapshotted before the matrix phase. PTO-v0
therefore permits destination/source, destination/bias, destination/scale, and
extra-operand aliases. If scale and bias operands alias one another, each role
observes the common pre-instruction value. Multi-stage operations never read a
value they wrote earlier through an aliased operand.

## Evidence contract

The canonical tile catalog and CUBE ASL units own the accepted function
inventory and raw-carrier/profile boundary. `TestCubeDecodedSelectorMatrix` executes
every accepted selector through decoded dispatch and checks its result.
Additional matrices cover all 25 type identities, mixed type/layout/location
execution, implementation-defined layout rejection, all 19 reserved function
codes, ten representative alias classes, and nine preflight failure roles with
complete destination preservation. The alias matrix covers destination-left,
destination-right, source-source, bias, both scale roles, extra-source,
accumulate, ACCCVT, and GEMV aliases. The preflight matrix covers destination,
left, right, bias, both scale roles, accumulator definedness, layout, and shape.

The repository checker derives function/name identity from the canonical tile
catalog and `release-traceability-readiness.json`, and fails closed if the ASL,
test entrypoints, or instruction-contract ownership drifts.

## Consequences

- CUBE reference semantics are total without presenting raw-carrier arithmetic
  as hardware numeric conformance.
- Composite helpers cannot partially update a destination before discovering
  an invalid later bias or scale operand.
- Alias behavior is snapshot-based and independent of helper call order.
- Adding a new type, selector, layout class, or numeric profile requires an
  explicit evidence update.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

CUBE matrix selectors combine multiple operands, optional bias or accumulator inputs, shape constraints, placement rules, and composite helper calls. Partial validation could update a destination before a later operand is found illegal.

CUBE 矩阵 selector 组合多个操作数、可选 bias 或 accumulator 输入、形状约束、放置规则和组合辅助调用。若分阶段验证，可能在发现后续操作数非法前已更新目的状态。

### Detailed decision / 详细决策

Each accepted raw carrier maps to one explicit CUBE operation contract with the listed type, Local/Shared placement, shape, definedness, and alias rules. Composite operations preflight all sources, descriptors, scales, bias/accumulator inputs, destinations, and capacities before snapshots; results and status publish atomically from those snapshots.

每个已接受原始载体映射到一个明确 CUBE 操作契约，并采用所列类型、Local/Shared 放置、形状、已定义性和别名规则。组合操作在快照前预检所有源、描述符、scale、bias/accumulator 输入、目的和容量；结果与状态基于快照原子发布。

### What changed / 改动内容

#### English

- Closed raw-carrier mappings and operand placement for the CUBE matrix family.
- Made composite validation and publication one fail-closed transaction.

#### 中文

- 闭合 CUBE 矩阵族的原始载体映射与操作数放置。
- 将组合验证与发布设为失败关闭的单一事务。

### Scope and boundaries / 范围与边界

This record governs carrier totality, placement, shapes, aliases, and transaction order. New types, selectors, layouts, or numeric choices require their own owner and evidence.

本记录管理载体完备性、放置、形状、别名和事务顺序。新增类型、selector、布局或数值选择必须由独立 owner 与证据支持。
