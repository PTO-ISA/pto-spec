<!-- GENERATED FROM: asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
# MSCATTER

**Normative ASL source:** `asl/tile/memory-and-data-movement/irregular/MSCATTER.asl`

Scatter the valid source region to GM at signed or unsigned byte displacements.

## Normative identity {#PTO-INST-TILE-MSCATTER}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-mscatter-purpose role=purpose -->
## MSCATTER 的作用

`MSCATTER` 是一条由 `TLSU` 执行、通过选择器编码的 Tile 操作。它把每个整数索引解释为 GM 字节位移，并存储相应的有效源元素；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-mscatter-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数把每个整数索引解释为 GM 字节位移，并存储相应的有效源元素。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-mscatter-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `address` 的精确契约角色是“基址”。
- `source0` 的精确契约角色是“源数据”。
- `source1` 的精确契约角色是“字节位移索引”。

操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-mscatter-effects role=effects -->
## 发布、已定义性与填充

只有源、谓词、地址与权限完成完整预检后，GM 写入和内存事件才开始；该操作没有 Tile 目标。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

操作在首次存储或内存事件前预检每个启用的 GM 地址，并且不分配目标 Tile。

<!-- PTO-READER-BLOCK: tile-mscatter-constraints role=constraints -->
## 类型、布局与故障边界

索引 Tile 使用 `S32`、`U32`、`S64` 或 `U64`。紧凑四位传输类型 `E2M1X2`、`E1M2X2`、`HiF4X2`、`S4X2` 与 `U4X2` 会被拒绝，因为该索引传输没有半字节选择器。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-mscatter-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `MSCATTER` 示例说明：索引 `4` 与源值 `7` 在完整预检后把 `7` 存到 `base + 4`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `memory-and-data-movement`
- **Execution engine:** `TLSU`

## Assembly

```asm
MSCATTER <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| MSCATTER | TLSU |  | 5 |  | MSCATTER |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| address | base-address |
| source0 | source data |
| source1 | byte-displacement indices |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractOperation_MSCATTER() => TileOperation
begin
    return TileOperation_MSCATTER;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.MSCATTER DataType
B.DATR Layout (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT DataTile, IndexTile, mask=PE_MASK, <last>
B.IOR BaseGPR, zero, zero, ->zero
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/memory-and-data-movement/irregular/MSCATTER.asl -->
```asl
readonly func InstructionContractHandler_MSCATTER() => TileSemanticHandler
begin
    return TileHandler_MSCATTER;
end;

pure func InstructionContractUsesByteDisplacements_MSCATTER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.
- LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.
- Omitted B.DATR selects Layout=NORM. PadValueOrByteId and every other B.DATR field must remain zero.
- Each IndexTile logical element is a signed or unsigned byte displacement added directly to BaseGPR.

## Legality

- MSCATTER is selected only by BSTART.MSCATTER function 5 in the TLSU selector space; it has no standalone opcode.
- Exactly one terminating Local B.IOT supplies DataTile and IndexTile with no destination or TSize. B.IOS and additional Tile bindings are not accepted.
- DataTile and IndexTile must be allocated and fully defined. DataTile DataType must equal the BSTART transfer DataType. IndexTile must use S32, U32, S64, or U64.
- DataTile physical Col equals resolved LB2. Both sources have resolved ValidRow x ValidCol and selected Layout; IndexTile may use a different physical shape outside that valid rectangle.
- Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.
- B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, dimension, address, permission, event, or memory checks.
- B.DATR applicability allows only Layout.

## State effects

- Source Tile descriptors and payloads persist unchanged after success or rejection.
- On success only memory and memory-event state change; MSCATTER allocates no destination Tile.

## Memory effects and ordering

### Memory effects

- For every valid coordinate, store the corresponding DataTile element to BaseGPR plus the sign- or zero-extended byte displacement in the IndexTile coordinate.
- Only ValidRow x ValidCol is written; source physical elements outside the valid rectangle have no memory effect.
- All valid-lane addresses are preflighted before stores. Duplicate or overlapping target addresses have an implementation-defined final winner.

### Ordering

- No lane or inter-PE issue order is architecturally guaranteed.
- B.CATR.atomic=1 makes the complete block memory effect non-interleavable but does not define an internal lane order or a duplicate-address winner.

## Exceptions

- A missing B.IOR, missing LB0, malformed B.IOT, undefined source, source DataType mismatch, non-integer IndexTile, shape or layout mismatch, invalid dimensions, or packed four-bit transfer DataType raises Fault_TileLegality before memory events or writes.
- Every valid-region address is generated and probed before the first store or event; any access fault produces no partial memory or event effect.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.

## Examples

- BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP
