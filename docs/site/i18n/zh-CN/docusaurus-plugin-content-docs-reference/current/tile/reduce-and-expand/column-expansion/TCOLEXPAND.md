<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl -->
# TCOLEXPAND

**Normative ASL source:** `asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl`

Broadcast one one-row vector source bit-for-bit into a new Local destination.

## Normative identity {#PTO-INST-TILE-TCOLEXPAND}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolexpand-purpose role=purpose -->
## TCOLEXPAND 的作用

`TCOLEXPAND` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它把单行广播源逐位复制到每个有效目标行；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tcolexpand-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数把单行广播源逐位复制到每个有效目标行。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tcolexpand-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“新分配的 Local 同类型数值目标”。
- `source0` 的精确契约角色是“持久 Local 单行广播源”。

参与操作的源与目标描述符采用所选的 RowMajor、CUBE_M16 或 CUBE_M32 布局，并遵循当前契约规定的逻辑形状关系。
操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-tcolexpand-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tcolexpand-constraints role=constraints -->
## 类型、布局与故障边界

精确的可接受类型或类型组合由下方生成的合法性章节拥有；本指南不会扩大该集合。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tcolexpand-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TCOLEXPAND` 示例说明：单行源 `[10, 20]` 原样广播到每个有效目标行。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLEXPAND <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPAND | TEPL | 0x054 | 20 | 2 | ExecuteTileExpand |

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
| destination0 | new Local same-type numeric destination |
| source0 | persistent Local one-row broadcast source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPAND() => TileOperation
begin
    return TileOperation_TCOLEXPAND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLEXPAND, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPAND.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLEXPAND(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLEXPAND(
    destination: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Column,
        destination,
        broadcast,
        broadcast);
end;

readonly func InstructionContractHandler_TCOLEXPAND() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TCOLEXPAND(
    destination: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLEXPAND(
        destination,
        broadcast);
    ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Column,
        destination,
        broadcast,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For every valid destination element, copy BroadcastTile[0,c] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.

## Legality

- TCOLEXPAND is selected by the TEPL raw encoding carrier Mode 2 Function 20; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent one-row source and one newly allocated Local destination; no full-shape second source exists.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The destination DataType equals the broadcast source DataType.
- The broadcast source has logical ValidRow equal to one and ValidCol equal to the destination; physical extents are derived from the selected layout.
- The destination geometry is the B.DIM-derived geometry.
- Every source is a fully defined numeric Tile in the selected RowMajor, CUBE_M16, or CUBE_M32 layout with valid numeric encodings.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For every valid destination element, copy BroadcastTile[0,c] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.
- Publish the complete renamed destination atomically after every element succeeds.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.
- All source payloads are snapshotted before result construction; sources persist and legal aliases use read-old/write-new behavior.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Examples

- BSTART.SFU TCOLEXPAND, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
