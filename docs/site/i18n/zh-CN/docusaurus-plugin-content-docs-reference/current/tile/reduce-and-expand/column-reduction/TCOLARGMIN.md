<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-reduction/TCOLARGMIN.asl -->
# TCOLARGMIN

**Normative ASL source:** `asl/tile/reduce-and-expand/column-reduction/TCOLARGMIN.asl`

Reduce each valid column to its lowest minimum row index with exact typed row-order semantics.

## Normative identity {#PTO-INST-TILE-TCOLARGMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolargmin-purpose role=purpose -->
## TCOLARGMIN 的作用

`TCOLARGMIN` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它按行号递增顺序扫描每一列，并返回最小值所在的最低行号；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tcolargmin-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数按行号递增顺序扫描每一列，并返回最小值所在的最低行号。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tcolargmin-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“采用 U32 的新 Local 索引目标”。
- `source0` 的精确契约角色是“持久 Local 数值源”。

参与操作的源与目标描述符采用所选的 RowMajor、CUBE_M16 或 CUBE_M32 布局，并遵循当前契约规定的逻辑形状关系。
操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-tcolargmin-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tcolargmin-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `FP32`, `FP16`, `BF16`, `S32`, `S16`, `S8`, `U32`, `U16`, `U8`。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tcolargmin-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TCOLARGMIN` 示例说明：列数据 `[[1, 4], [3, 2]]` 产生最低获胜行索引 `[0, 1]`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLARGMIN <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLARGMIN | TEPL | 0x05D | 29 | 2 | ExecuteTileReduction |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.PadValueOrByteId (`PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID`)

Carries the operation-selected PadValue or ByteId union field.

**Encoded zero:** For PadValue operations code zero selects Zero; for ByteId operations it selects ByteId zero.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | Zero-or-ByteId0 |
| 1 | assigned | Max-or-ByteId1 |
| 2 | assigned | Min-or-ByteId2 |
| 3 | assigned | Null-or-ByteId3 |

**Reserved-value behavior:** All four encodings are assigned; the selected operation separately validates whether the field is PadValue, ByteId, or inapplicable.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local U32 index destination |
| source0 | persistent Local numeric source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-reduction/TCOLARGMIN.asl -->
```asl
readonly func InstructionContractOperation_TCOLARGMIN() => TileOperation
begin
    return TileOperation_TCOLARGMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLARGMIN, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-reduction/TCOLARGMIN.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLARGMIN(
    data_type: TileDataType) => boolean
begin
    return TileArgReductionSourceDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLARGMIN(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_ARGMIN,
        TileAxis_Column,
        destination,
        source);
end;

readonly func InstructionContractHandler_TCOLARGMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TCOLARGMIN(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLARGMIN(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_ARGMIN,
        TileAxis_Column,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TCOLARGMIN computes an increasing-row TMIN scan that retains the lowest winning index; the scan order is architectural and tree reassociation is not permitted.

## Legality

- TCOLARGMIN is selected by the TEPL raw encoding carrier Mode 2 Function 29; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.
- The source DataType is exactly S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- The destination DataType is U32 regardless of source DataType.
- The source is a fully defined numeric Tile in the selected RowMajor, CUBE_M16, or CUBE_M32 layout whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; every constrained floating encoding is valid. The reduction source allocated capacity is at most 2048 bytes and is checked before the source snapshot or destination allocation.
- The destination has logical ValidRow equal to one and ValidCol equal to source.ValidCol; its physical geometry is derived from the selected layout and capacity.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For each valid column, compute an increasing-row TMIN scan that retains the lowest winning index.
- Write the selected row index as U32; equal winning values retain the lowest index.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle, then publish the complete result atomically.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes the source snapshot.
- The source is scanned in strictly increasing row order; the source persists and is never modified.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable result shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- Floating numeric status is accumulated across the architectural fold and publishes atomically with the result.

## Examples

- BSTART.SFU TCOLARGMIN, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
