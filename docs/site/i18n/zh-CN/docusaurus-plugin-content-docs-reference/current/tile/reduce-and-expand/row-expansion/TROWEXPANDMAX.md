<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-expansion/TROWEXPANDMAX.asl -->
# TROWEXPANDMAX

**Normative ASL source:** `asl/tile/reduce-and-expand/row-expansion/TROWEXPANDMAX.asl`

Take the typed maximum of a full-shape source and a broadcast one-column vector.

## Normative identity {#PTO-INST-TILE-TROWEXPANDMAX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowexpandmax-purpose role=purpose -->
## TROWEXPANDMAX 的作用

`TROWEXPANDMAX` 在每个有效行上与单列广播取最大值。

<!-- PTO-READER-BLOCK: tile-c-trowexpandmax-mechanism role=mechanism -->
## 操作机制

广播源的物理列与有效列都是一；其行值会复用于每个有效目标列。

若存在完整形状源，则它与广播源都会在构造结果前完成快照。

浮点结果与元素状态遵循当前具名数值配置档；可移植契约拥有选择、形状、发布与故障顺序。

<!-- PTO-READER-BLOCK: tile-c-trowexpandmax-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 标识新分配的目的 Tile。

- `source0` 提供持久源 Tile。

- `source1` 提供持久源 Tile。

- 封闭的适用 DataType 集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。

- 除非该助记符显式选择其他允许布局，数据 Tile 使用行主序布局。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-trowexpandmax-effects role=effects -->
## 已定义性、填充与发布

所有源描述符与载荷都会在目标发布前完成验证和快照。

完整目标载荷、描述符、已定义性、填充状态与适用数值状态会原子发布；拒绝路径不发布任何部分。

Null 填充让有效矩形外的物理坐标保持未定义；显式非 Null 填充值会用选定带类型的值定义这些位置。

源 Tile 在成功执行后保持不变。

<!-- PTO-READER-BLOCK: tile-c-trowexpandmax-constraints role=constraints -->
## 合法性、故障与顺序边界

完整绑定模式、维度、DataType、布局、源已定义性、数值编码、目标容量与分配都会在效果前预检。

合法性或分配检查失败会引发相应 Tile 故障，不留下部分目标、状态或内存效果。

`PE_MASK=0000` 是严格无操作，发生在操作数读取、分配、故障、数值状态或载荷效果之前。

<!-- PTO-READER-BLOCK: tile-c-trowexpandmax-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TROWEXPANDMAX <bundle operands>` 先完成完整预检与源快照，再原子发布助记符定义的结果与填充状态。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWEXPANDMAX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDMAX | TEPL | 0x049 | 9 | 2 | ExecuteTileExpand |

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
| source0 | persistent Local full-shape numeric source |
| source1 | persistent Local one-column broadcast source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-expansion/TROWEXPANDMAX.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDMAX() => TileOperation
begin
    return TileOperation_TROWEXPANDMAX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWEXPANDMAX, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-expansion/TROWEXPANDMAX.asl -->
```asl
pure func InstructionContractDataTypeLegal_TROWEXPANDMAX(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWEXPANDMAX(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_MAX,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPANDMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPANDMAX(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPANDMAX(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_MAX,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For every valid destination element, compute typed max(source0[r,c], BroadcastTile[r,0]) at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TMAX typed operation.

## Legality

- TROWEXPANDMAX is selected by the TEPL raw encoding carrier Mode 2 Function 9; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent one-column broadcast source, and one newly allocated Local destination.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The destination and both sources use exactly the selected DataType.
- The broadcast source has ValidRow equal to the destination, the orthogonal valid extent equal to one, and physical Col equal to one.
- The full-shape source and destination have identical physical and valid geometry equal to the B.DIM-derived geometry.
- Every source is a fully defined row-major numeric Tile with valid numeric encodings.
- PadValueOrByteId is the only applicable B.DATR field. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For every valid destination element, compute typed max(source0[r,c], BroadcastTile[r,0]) at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TMAX typed operation.
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

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, non-row-major source, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Examples

- BSTART.SFU TROWEXPANDMAX, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
