<!-- GENERATED FROM: asl/tile/model/state/local-registers.asl -->
# Local Registers

**Normative ASL source:** `asl/tile/model/state/local-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-LOCAL-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-local-registers-purpose role=purpose-scope -->
## 用途与范围

本单元声明架构 Tile 状态。它篇幅很短，但 Tile 操作会读取或写入它所命名的变量。

它声明两个状态所有者：

- `PTO-STATE-TILE-LOCAL`，成员为 `_Tiles`、`_TileAllocationMasks`、`_TileRelativeOrder` 和 `_TileRelativeValid`。
- `PTO-STATE-TILE-SHARED`，唯一成员为 `_SharedTiles`。

它还带有两条已接受的 NDF 要求：`PTO-REQ-TILE-001` 和 `PTO-REQ-SHARED-TILE-001`。

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-concepts role=concepts-state -->
## 概念与可见状态

| 变量 | 形状 | 含义 |
| --- | --- | --- |
| `_Tiles` | 64 条 `TileInfo` 记录 | 每个 Local Tile 寄存器的描述符、已定义性和载荷 |
| `_TileAllocationMasks` | 64 个四位掩码 | 持有每个 Local 分配的 PE |
| `_TileRelativeOrder` | 4 个 hand，每个 16 个寄存器索引 | 每个 hand 的相对代次顺序 |
| `_TileRelativeValid` | 4 个 hand，每个 16 位 | 哪些相对条目处于存活状态 |
| `_SharedTiles` | 64 条 `SharedTileInfo` 记录 | Core 私有的 Shared 寄存器 S0 到 S63 |

两个状态所有者都声明作用域为 `core`。Local 状态按绝对寄存器编号 0 到 63 索引，描述符辅助函数把它们分组为 hand T、U、M 和 N。

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-rules role=rules-interactions -->
## 规则与交互

`PTO-REQ-TILE-001` 规定相对命名。在 T、U、M、N 每个 hand 中，`#1` 是最新发布的代次。当该 hand 的新目标发布时，较早的存活代次向 `#16` 移动。源代次必须保持存在。

`PTO-REQ-SHARED-TILE-001` 规定 Shared 寄存器恰好就是名为 `PTO-STATE-TILE-SHARED` 的 Core 私有状态。

设计要点：相对顺序是架构状态，而不是编译器约定。由于 `_TileRelativeOrder` 和 `_TileRelativeValid` 是 `PTO-STATE-TILE-LOCAL` 的成员，像 `#2` 这样的相对选择子的含义只会通过该状态上已接受的 ASL 转换而改变。

设计要点：分配掩码存放在 `_Tiles` 旁边，而不是 `TileInfo` 内部。Local 容量辅助函数读取 `_TileAllocationMasks`，只向每个 PE 计入指明该 PE 的对象。

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-boundaries role=boundaries -->
## 架构边界

本单元只声明状态。改变状态的转换由其他单元拥有：分配与释放、相对发布、Shared 发布，以及系统寄存器所有者中的复位例程。

`PTO_TILE_REGISTER_COUNT` 和 `PTO_SHARED_TILE_COUNT` 都是 64。每个 `TileInfo` 中的载荷受模型常量 `PTO_MODEL_TILE_ELEMENTS` 限制，它是模型界限，而不是对实现的要求。

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-example role=example-usage -->
## 非规范阅读示例

要回答“PE1 当前持有哪些 Local Tile？”，按以下顺序读取状态：

1. 对寄存器 0 到 63 中的每一个，检查 `_Tiles` 条目的 `allocated`。
2. 检查该寄存器在 `_TileAllocationMasks` 中的位 2，因为 PE1 映射到掩码位 3 - 1 = 2。
3. 两项检查都通过的寄存器就是 PE1 的 Local 对象，它们的 `capacity_bytes` 之和就是 PE1 的 Local 池用量。

要回答“hand U 中的 `#2` 是什么意思？”，读取 `_TileRelativeOrder` 的 hand 1 距离 1，并确认 `_TileRelativeValid` 中对应的位。

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-related role=related-owners-navigation -->
## 相关所有者

- [类型](types.md)定义 `TileInfo` 和 `SharedTileInfo`。
- [描述符](descriptors.md)实现相对解析与发布。
- [分配](allocation.md)和 [Shared 寄存器](shared-registers.md)拥有该状态上的主要转换。
- [Local 容量](../capacity/local.md)读取分配掩码。
- [Tile 寄存器](../../../arch/programming-model/tile-registers.md)给出架构层面的视图。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/local-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","surface":"tile","classification":["model","state","local-registers"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES"]}
// PTO-STATE: {"id":"PTO-STATE-TILE-LOCAL","classification":["tile","local"],"scope":"core","owner":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","members":["_Tiles","_TileAllocationMasks","_TileRelativeOrder","_TileRelativeValid"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-TILE-SHARED","classification":["tile","shared"],"scope":"core","owner":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","members":["_SharedTiles"],"depends_on":[]}

// NDF-BEGIN: PTO-REQ-TILE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local Tile registers and their allocation masks MUST be the state defined by
// [[PTO-STATE-TILE-LOCAL]]. Each T/U/M/N hand MUST resolve #1 as its newest
// published generation and shift older live generations toward #16 whenever
// a new destination for that hand publishes. Source generations MUST persist.
// NDF-END: PTO-REQ-TILE-001

// NDF-BEGIN: PTO-REQ-SHARED-TILE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Shared Tile registers MUST be the core-private state defined by
// [[PTO-STATE-TILE-SHARED]].
// NDF-END: PTO-REQ-SHARED-TILE-001

var _Tiles : array [[PTO_TILE_REGISTER_COUNT]] of TileInfo;
var _TileAllocationMasks : array [[PTO_TILE_REGISTER_COUNT]] of bits(4);
var _TileRelativeOrder : RelativeTileSnapshot;
var _TileRelativeValid : RelativeTileValiditySnapshot;
var _SharedTiles : SharedTileSnapshot;
```
<!-- GENERATED-ASL-END: unit -->
