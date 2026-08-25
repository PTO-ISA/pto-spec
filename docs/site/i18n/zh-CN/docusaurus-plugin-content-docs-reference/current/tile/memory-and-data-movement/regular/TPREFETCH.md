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
## 用途

`TPREFETCH` 为全部四个 PE 预取带类型和步幅的 GM 矩形，不产生 Tile 目的地。

<!-- PTO-READER-BLOCK: tile-tprefetch-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_TPREFETCH`。

第一次请求或事件之前，必须预检全部四个 PE 的地址范围；该操作没有 Tile 或 Shared 目的地。

<!-- PTO-READER-BLOCK: tile-tprefetch-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`address` 是每 PE GM 基址；`scalar0` 是每 PE 的元素行步幅；`positive0` 是ValidCol；`positive1` 是ValidRow；`positive2` 是物理 Col。

`TPREFETCH` 不产生目的描述符或 Tile 状态；成功时唯一的架构贡献是带类型的内存事件序列。

<!-- PTO-READER-BLOCK: tile-tprefetch-effects role=effects -->
## 发布与排序

成功时为带步幅矩形发出与 TLOAD 等价的带类型载入事件，但不暴露架构缓存放置或保留状态。

块的 aq/rl 属性提供与 TLOAD 相同的 PTO-TSO 排序。

<!-- PTO-READER-BLOCK: tile-tprefetch-constraints role=constraints -->
## 合法性、填充与故障

第一次请求或事件之前，必须验证维度、数据属性和合并后的四 PE 内存访问范围。

任何内存故障都会拒绝整个预取，不产生部分事件序列，也不改变 Tile、Shared、描述符、载荷、已定义性或分配状态。

<!-- PTO-READER-BLOCK: tile-tprefetch-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.TPREFETCH U8; B.DIM zero, 16, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 32, ->LB2; B.IOR zero, a0; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
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

## State effects

- No destination Tile exists and no Tile or Shared state changes.
- A successful attempt contributes only its typed memory-access and ordering events.

## Memory effects and ordering

### Memory effects

- For each PE, prefetch the same typed, strided ValidRow x ValidCol GM footprint that TLOAD would read from that PE's private base and row-stride GPR values.
- The operation records TLOAD-equivalent typed-element load events but produces no destination. Cache placement and retention are not architecturally visible.

### Ordering

- Preflight all addresses and permissions for all four PEs before any event.
- Use CurrentBundleMemoryOrder so aq/rl and PTO-TSO behavior match TLOAD.

## Exceptions

- Malformed dimensions, unsupported data attributes, any B.IOT or B.IOS, or any memory fault in the combined four-PE footprint rejects before the first request or event.
- A rejected or faulting attempt changes no Tile, Shared, descriptor, payload, definedness, or allocation state.

## Examples

- BSTART.TPREFETCH U8; B.DIM zero, 16, ->LB0; B.DIM zero, 4, ->LB1; B.DIM zero, 32, ->LB2; B.IOR zero, a0; BSTOP
