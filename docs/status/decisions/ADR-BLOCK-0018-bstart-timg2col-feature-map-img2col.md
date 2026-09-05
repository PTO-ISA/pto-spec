---
{
  "id": "ADR-BLOCK-0018",
  "title": "BSTART.TIMG2COL feature-map IMG2COL and legacy Local-Tile retirement",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "zhoubot"
  ],
  "created": "2026-09-02",
  "accepted": "2026-09-02",
  "rejected": null,
  "superseded": null,
  "baseline": "13d550f4f63c6321f94e5c6b09da4c3986081841",
  "target_releases": [
    "0.58.6.0"
  ],
  "release_boundary": true,
  "interface_change": true,
  "affected_ndf": [
    "PTO-BSTART-TIMG2COL-CONTRACT-001",
    "PTO-BSTART-TIMG2COL-PARAMS-001",
    "PTO-BSTART-TIMG2COL-COOPERATIVE-001",
    "PTO-BSTART-TIMG2COL-CROP-001",
    "PTO-BSTART-TIMG2COL-DEFINEDNESS-001",
    "PTO-INST-BLOCK-B-DIM",
    "PTO-INST-BLOCK-BSTART-TIMG2COL",
    "PTO-INST-TILE-TIMG2COL",
    "PTO-TIMG2COL-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES",
    "PTO-BLOCK-BSTART-TIMG2COL",
    "PTO-BLOCK-B-DIM",
    "PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-EXECUTION",
    "PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA",
    "PTO-BLOCK-MODEL-MEMORY-TIMG2COL-GM",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-TIMG2COL-PARAMETERS",
    "PTO-BLOCK-MODEL-STATE-SHARED-GENERATION",
    "PTO-TILE-MODEL-EXECUTION-IMAGE-TO-COLUMN",
    "PTO-TILE-MODEL-LEGALITY-IMAGE-TO-COLUMN",
    "PTO-TILE-TIMG2COL"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/99",
  "release_impact": "required",
  "legacy_ids": [],
  "title_zh": "BSTART.TIMG2COL 特征图 IMG2COL 与旧 Local-Tile 退役"
}
---
# ADR-BLOCK-0018: BSTART.TIMG2COL feature-map IMG2COL and legacy Local-Tile retirement

## Context

Issue #99 replaces the retired Local-Tile `TIMG2COL` behavior with the frozen
feature-map operation carried by `BSTART.TIMG2COL`. The current contract and
its executable/catalog projections are the normative owners; this ADR records
the accepted decision, its `0.58.5.1` publication target, and its retirement scope.

## Decision

Only the frozen feature-map `BSTART.TIMG2COL` form is supported. It expands a
dense GM feature map through IMG2COL and publishes the defined Shared ND or
Local `CUBE_M16`/`CUBE_M32` result according to the Issue #99 contract. The
operation is fixed to batch size one and does not add weight loading, batch
greater than one, sparse GM, PE-level matmul, or packed-format semantics. It
does not add unsupported DataTypes, including the DataTypes excluded by the
frozen Issue #99 contract.

The base parameter version requires ParamGPR1 bit 54, `ParamVersion`,
`ExtensionClass`, and bit 63 to be zero. Shared cooperative destination ranges
start at destination row zero and use only the preceding-PE row prefix; the
encoded `RowStart` remains a source-crop coordinate. For direct Local CUBE
output, `TotalCol` is the virtual intermediate ND pitch used for composition
equivalence, while the persistent CUBE geometry is derived from `ValidCol`.

The old Local-Tile `TIMG2COL` semantics are fully removed. The former TEPL
selector `0x064` has no active Local-Tile catalog or decoder owner and is no
longer accepted; it is reserved-illegal in the current public partition. The
only accepted IMG2COL command form is `BSTART.TIMG2COL`.

This ADR **scoped-supersedes only ADR-0080 Decision 128** for the IMG2COL
feature-map and legacy Local-Tile retirement covered by Issue #99. It does not
supersede ADR-0080 as a whole, does not rewrite ADR-0080's historical record,
and does not change its metadata relationships.

Issue #208 is unaffected by this decision. Its separately frozen changes and
owners remain authoritative.

## Release targeting / 发布目标

This accepted ADR targets the PTO ISA `0.58.5.1` publication candidate. The
assignment covers the Issue #99 NDF and ASL drift,
including the retired `PTO-TILE-TIMG2COL` baseline scope. Publication still
requires the exact candidate to pass the protected release workflow. Current
decode, legality, operation, state-transition, definedness, and fault behavior
remain owned by the affected ASL/NDF clauses and their generated projections.

本 ADR 的目标版本为 `unassigned`。这不表示 Issue #99 已包含在或已发布于
PTO ISA `0.58.5`；当前尚未进行版本分配。本 ADR 记录 Issue #99 的 NDF 与
ASL 漂移，包括已退役的 `PTO-TILE-TIMG2COL` 基线范围；当前的解码、合法性、
操作、状态转换、definedness 和 fault 行为仍由受影响的 ASL/NDF 条款及其
生成投影负责。


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Issue #99 requires one active feature-map IMG2COL interface owned by the
block/TLSU path while retiring the incompatible Local-Tile form. Keeping both
forms active would leave the IMG2COL selector and publication projections
ambiguous.

Issue #99 要求由 block/TLSU 路径拥有唯一有效的特征图 IMG2COL 接口，同时
退役不兼容的 Local-Tile 形式。两种形式同时有效会使 IMG2COL 选择器和
publication 投影产生歧义。

### Detailed decision / 详细决策

The accepted Issue #99 contract is `BSTART.TIMG2COL` with its frozen dense-GM
source, crop, Shared publication, Local CUBE, cooperative, definedness, and
fault behavior. The former Local-Tile owner is retained only as historical
retired/reserved-illegal evidence.

An anonymized independent convolution-design comparison corroborates the
32-byte C0 grouping, Hout*Wout by kernel/channel matrix expansion, explicit
M/K crop, injected spatial padding, and tiled matrix destination. PTO does not
import target-local buffer names, persistent configuration registers, repeat,
transpose, dual-source operation, target alignment, warning/NOP behavior, or
pipeline timing from that comparison.

The comparison snapshot and PTO disposition are recorded without source
identity in `spec/evidence/timg2col-independent-design-comparison.json`
(SHA-256 `670174008299a58c25b8fc365a079980b4bf663508812d23c11211ed3026055e`).

已接受的 Issue #99 合同是 `BSTART.TIMG2COL`，其冻结的 dense-GM 源、裁剪、
Shared 发布、Local CUBE、协作、definedness 和 fault 行为保持不变。原有
Local-Tile owner 仅作为历史退役/保留非法证据保留。

基础参数版本要求 ParamGPR1 的 bit 54、`ParamVersion`、`ExtensionClass` 与
bit 63 全部为零。Shared 协作目标范围从目标第零行开始，只加入前序 PE 的行
前缀；编码的 `RowStart` 仅表示源裁剪坐标。对于直接 Local CUBE 输出，
`TotalCol` 是组合等价所使用的虚拟中间 ND 行距，持久 CUBE 几何由
`ValidCol` 推导。

匿名独立卷积设计对照确认了 32-byte C0 分组、Hout*Wout 与卷积核/通道形成的
矩阵展开、显式 M/K 裁剪、空间填充注入以及分块矩阵目标。PTO 不从该对照引入
目标本地缓冲区名称、持久配置寄存器、repeat、transpose、dual-source、目标
对齐、warning/NOP 行为或流水线时序。

对照快照及 PTO 处置以匿名方式记录在
`spec/evidence/timg2col-independent-design-comparison.json`，其 SHA-256 为
`670174008299a58c25b8fc365a079980b4bf663508812d23c11211ed3026055e`。

### What changed / 改动内容

#### English

- Migrated this accepted record from the temporary `ADR-0111` identity to
  `ADR-BLOCK-0018`, the next available BLOCK serial in the current schema.
- Kept the scoped relationship to `ADR-0080` / `ADR-TILE-0008` Decision 128
  in the prose only; neither record is superseded as a whole.
- Closed the base extension-value, source-versus-destination row-origin, and
  Local `TotalCol` interpretation gaps using the accepted Issue #99 direction.
- Left Issue #208 and its owners unchanged.

#### 中文

- 将本已接受记录从临时 `ADR-0111` 标识迁移到当前 schema 中下一个可用的
  BLOCK 序号 `ADR-BLOCK-0018`。
- 仅在正文中保留与 `ADR-0080` / `ADR-TILE-0008` Decision 128 的限定关系；
  不整体 supersede 任一记录。
- 按 Issue #99 已接受方向闭合基础扩展值、源/目标行起点以及 Local
  `TotalCol` 解释缺口。
- Issue #208 及其 owner 保持不变。

### Scope and boundaries / 范围与边界

This record changes ADR identity and records the Issue #99 interface decision;
it does not redefine the frozen ASL/NDF semantics or alter unrelated block,
tile, cube, or Issue #208 decisions.

本记录只变更 ADR 标识并记录 Issue #99 接口决策；不重新定义冻结的 ASL/NDF
语义，也不改变无关的 block、tile、cube 或 Issue #208 决策。
