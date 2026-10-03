<!-- GENERATED FROM: asl/tile/memory-and-data-movement/regular/TPREFETCH.asl -->
# TPREFETCH

**Normative ASL source:** `asl/tile/memory-and-data-movement/regular/TPREFETCH.asl`

Prefetches a typed, strided GM rectangle for all four PEs without producing a Tile destination.

## Normative identity {#PTO-INST-TILE-TPREFETCH}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tprefetch-purpose role=purpose -->
## TPREFETCH 的作用

`TPREFETCH` 为全部四个 PE 读取一个带类型的、带步幅的 GM 矩形，并且不产生目标。它是 TLSU Function 3，写作 `BSTART.TPREFETCH DataType`，并且没有独立 opcode。

该指令束具有隐式 PE 参与 `1111`，且不绑定任何 Local 或 Shared Tile：指令束中任何 `B.IOT` 或 `B.IOS` 都是模式错误并会引发故障。

<!-- PTO-READER-BLOCK: tile-tprefetch-mechanism role=mechanism -->
## 足迹与排序

对四个 PE 中的每一个，足迹都是与 `TLOAD` 从该 PE 私有基址与行步幅 GPR 值读取时相同的带类型 `ValidRow` x `ValidCol` 矩形。地址由 `TileMemoryIndexedAddress` 构造，因此 `scalar0` 以逻辑元素计数：该辅助函数对普通类型乘以 `TileElementBytes`，对打包四位类型把索引右移一位，因此一个逻辑元素前进半个字节。

`TPREFETCHCore` 执行两遍。第一遍以读访问探测每个 PE 的每个带类型元素；第二遍载入每个转换后的地址，并为该 PE 记录一个带类型的 load 事件，携带 `CurrentBundleMemoryOrder()`。

设计要点：四个 PE 的足迹都在第一个事件之前被探测，因此任一 PE 的故障都会拒绝整个预取，且不留下部分事件前缀。`TLOAD` 的行为不同：它在首个故障处停止，并保留已经记录的事件。

省略 `B.IOR` 时，每个 PE 的基址为零，行步幅为紧密步幅，即以元素计数的解析物理 `Col`。显式编码的零选择子是真正的零步幅，因此每一行都会别名到第 0 行。

<!-- PTO-READER-BLOCK: tile-tprefetch-inputs-outputs role=inputs-outputs -->
## 操作数角色与绑定

- `address` 是每 PE 的 GM 基址。
- `scalar0` 是每 PE 以元素计的逻辑行步幅。
- `positive0` 是 `ValidCol`。
- `positive1` 是 `ValidRow`。
- `positive2` 是物理 `Col`。

`LB0`、`LB1` 与 `LB2` 提供这些维度。省略 `LB0` 或 `LB1` 时选择 `1`，省略 `LB2` 时选择解析出的 `ValidCol`。

设计要点：每个 PE 从自己的私有 GPR 文件读取基址与步幅，因此一次预取可以覆盖四个不同的 GM 区域，而形状对它们保持公共。

<!-- PTO-READER-BLOCK: tile-tprefetch-effects role=effects -->
## 改变的内容

成功的预取不改变任何 Tile、Shared、描述符、payload、已定义性或分配状态。它唯一的架构贡献是带类型的内存访问与排序事件序列。

这些事件是 `TLOAD` 对相同足迹会记录的带类型元素 load 事件，但没有任何值被发布到任何位置。

设计要点：`InstructionContractPublishesTileDestination_TPREFETCH` 为 `FALSE`，并且契约声明缓存放置与保留在架构上不可见，因此可观察结果是事件序列，而不是数据存在于任何缓存中。

<!-- PTO-READER-BLOCK: tile-tprefetch-constraints role=constraints -->
## 类型、形状与故障

`InstructionContractDataTypeLegal_TPREFETCH` 接受 `TileCarrierOrPackedBaselineDataTypeSupported` 允许的类型：最高 64 位的非打包载体，加上打包四位基线。

`ValidCol` 与 `ValidRow` 为正，`Col` 是非零的 2 的幂且至少为 `ValidCol`，并且 `ValidRow * ValidCol` 不得超过 `PTO_MODEL_TILE_ELEMENTS`。`B.DATR` 只允许 `Layout` 作为非零操作属性，并要求填充并集保持为零。

维度错误、数据属性不受支持、出现任何 `B.IOT` 或 `B.IOS`，或四个 PE 合并足迹中的内存故障，都会在第一个事件之前拒绝，并且不改变任何 Tile、Shared、描述符、payload、已定义性或分配状态。

设计要点：参与是隐式 `1111`，且模式不接受任何 Tile 绑定，因此指令束既不能把预取限制到部分 PE，也不能为它附加目标。

<!-- PTO-READER-BLOCK: tile-tprefetch-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

取 `U8`、`Row=4`、`Col=16`、`ValidRow=4` 与 `ValidCol=16`，其中 `a0` 保存每个 PE 的 GM 基址，`a1` 保存 `16` 个元素的紧密行步幅。规范宏写法是 `TPREFETCH <Row=4, Col=16, ValidCol=16, U8>, [base=a0, stride=a1]`。

- 每个 PE 的足迹是 `4 * 16 = 64` 个带类型元素，因此四个 PE 合起来探测并记录 `256` 个元素事件。
- 省略 `B.IOR` 时每个 PE 得到基址 `0` 与步幅 `16`；编码的零选择子则提供真正的零值。
- 任一 PE 的任一元素发生故障都不会产生任何事件，因为覆盖四个 PE 的探测遍先执行。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
TPREFETCH <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TPREFETCH | TLSU |  | 3 |  | TPREFETCH |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | per-PE GM base |
| scalar0 | per-PE logical row stride in elements |
| positive0 | ValidCol |
| positive1 | ValidRow |
| positive2 | physical Col |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/regular/TPREFETCH.asl -->
```asl
readonly func InstructionContractOperation_TPREFETCH() => TileOperation
begin
    return TileOperation_TPREFETCH;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TPREFETCH DataType
B.DATR Layout (optional)
B.DIM LB0/ValidCol, LB1/ValidRow, LB2/Col (optional)
B.IOR base,row_stride (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/regular/TPREFETCH.asl -->
```asl
pure func InstructionContractDataTypeLegal_TPREFETCH(
    code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileCarrierOrPackedBaselineDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_TPREFETCH() => TileSemanticHandler
begin
    return TileHandler_TPREFETCH;
end;

pure func InstructionContractPublishesTileDestination_TPREFETCH()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractUsesTLOADFootprint_TPREFETCH()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Omitted B.DATR selects NORM; omitted LB0 and LB1 each select one, and omitted LB2 selects resolved ValidCol.
- Omitted B.IOR supplies base zero and dense row stride equal to resolved Col for every PE. Explicit zero selectors remain actual zero values.

## Legality

- TPREFETCH is selected only by BSTART.TPREFETCH at TLSU Function 3 and has no standalone opcode.
- It has implicit participation 1111 and accepts no Local or Shared Tile binding.
- ValidCol and ValidRow are positive; Col is a nonzero power of two and is at least ValidCol.
- B.DATR permits only Layout as a nonzero operation attribute and requires the pad union to remain zero.
- The non-packed raw carrier domain includes B64; prefetch addressing remains the existing explicit element-stride contract.

## State effects

- No destination Tile exists and no Tile or Shared state changes.
- A successful attempt contributes only its typed memory-access and ordering events.

## Memory effects and ordering

### Memory effects

- For each PE, prefetch the same typed, strided ValidRow x ValidCol GM footprint that TLOAD would read from that PE's private base and row-stride GPR values.
- The operation records TLOAD-equivalent typed-element load events but produces no destination. Cache placement and retention are not architecturally visible.

### Ordering

- Preflight all addresses and permissions for all four PEs before any event.
- Use CurrentBundleMemoryOrder so aq/rl and PTO-RC behavior match TLOAD.

## Exceptions

- Malformed dimensions, unsupported data attributes, any B.IOT or B.IOS, or any memory fault in the combined four-PE footprint rejects before the first request or event.
- A rejected or faulting attempt changes no Tile, Shared, descriptor, payload, definedness, or allocation state.

## Examples

- BSTART.TPREFETCH U8; B.DIM zero, 16, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 32, ->LB2; B.IOR zero, a0; BSTOP
