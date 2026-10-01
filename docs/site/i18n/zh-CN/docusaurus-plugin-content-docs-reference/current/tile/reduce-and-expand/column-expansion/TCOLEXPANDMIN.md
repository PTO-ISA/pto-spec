<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDMIN.asl -->
# TCOLEXPANDMIN

**Normative ASL source:** `asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDMIN.asl`

Take the typed minimum of a full-shape source and a first-row column-broadcast source.

## Normative identity {#PTO-INST-TILE-TCOLEXPANDMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolexpandmin-purpose role=purpose -->
## TCOLEXPANDMIN 的作用

`TCOLEXPANDMIN` 是由 `SFU` 引擎执行的 Tile 归约与扩展操作。它把完整形状源与每个有效列的一个广播值结合：对每个目标坐标 `[r,c]` 计算 `typed min(source0[r,c], BroadcastTile[0,c])`，因此广播 Tile 为每个有效列提供一个值。它由 `TEPL` Mode 2 Function 26（选择器 `0x05A`）选中，没有独立 opcode。

设计要点：列扩展与对应的列归约在形状上互为逆操作：归约为每个有效列产生一个值，扩展则为每个有效列消费一个值并在每个有效行上复用，这也是广播操作数是 Tile 而不是标量的原因。

<!-- PTO-READER-BLOCK: tile-tcolexpandmin-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检之后，`ExecuteTileExpand` 独立计算每个目标坐标 `[r,c]`，即 `typed min(source0[r,c], BroadcastTile[0,c])`，其中 `source0[r,c]` 始终是左操作数，`BroadcastTile[0,c]` 始终是右操作数。整数结果停留在元素位宽上；浮点结果、异常值、带符号零行为与逐元素的数值状态标志与对应的 `TMIN` 有类型操作完全一致。

设计要点：操作数顺序由架构规定而不是可配置的，每个元素的状态按位或合并为一次事务，并与结果一起发布。

<!-- PTO-READER-BLOCK: tile-tcolexpandmin-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是持久 Local 完整形状源。其逻辑有效几何与布局必须与目标一致。

- `source1` 是持久 Local 列广播源。只有 `BroadcastTile[0,c]` 提供取值；后面的有效行会被忽略且不做编码校验，只有在不施加 ExecutionMask 时才必须已定义。

- `destination0` 是新分配的 Local Tile，DataType 为操作 DataType，几何由 `B.DIM` 推导；`LB0` 必需并提供非零 `ValidCol`，省略 `LB1` 选择 `ValidRow` 等于 1，省略 `LB2` 选择 `Col` 等于 `ValidCol`。其余物理坐标是填充坐标。

- 所有操作数使用同一布局，只有 `RowMajor`、`CUBE_M16` 与 `CUBE_M32` 是允许的布局。

- 各操作数共享同一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作，发生在描述符读取、分配、故障、状态或载荷效果之前。

设计要点：广播源只在被消费的位置检查。其有效列数必须与目标相同；不施加 ExecutionMask 时整个广播有效区域都必须已定义，施加 ExecutionMask 时只有至少含一个活动目标坐标的列所对应的 `BroadcastTile[0,c]` 必须已定义。其余广播元素不做编码校验。

设计要点：与归约不同，扩展接受共享的 Local CUBE ExecutionMask。非活动目标坐标取掩码的零值或合并值，而不是计算结果，也不贡献源读取与数值状态；带掩码时完整形状源必须与掩码的布局及两个有效范围一致。

<!-- PTO-READER-BLOCK: tile-tcolexpandmin-effects role=effects -->
## 发布、已定义性与填充

目标作为一个整体发布：描述符、每个有效结果、已定义性、有效矩形之外的填充与累积的数值状态同时出现，被拒绝的执行不会发布其中任何一项。两个源的载荷都在写入第一个目标元素前快照，因此合法别名读取旧的源值，源本身保持不变。

`ValidRow x ValidCol` 有效区域之外的物理目标坐标接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 会定义这些坐标；`Null` 使它们保持未定义。

设计要点：省略 `B.DATR` 选择 `Null`，而显式 `PadValue` 编码 `00` 选择 `Zero`。省略与编码零并不相同，因此要读取整个物理目标的程序必须请求 `Zero`、`Max` 或 `Min`。

<!-- PTO-READER-BLOCK: tile-tcolexpandmin-constraints role=constraints -->
## 类型、布局与故障边界

可接受的操作类型为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 与 `U8`，`BSTART` DataType 同时是源操作 DataType 与目标 DataType。每个源后备只有在等位宽、非打包载体视图下才允许与它不同；原始位按操作 DataType 解释，不重新打标签，也不做数值转换。

- 恰好一条终止的 Local `B.IOT` 提供各操作数与一个新分配的 Local 目标；`B.IOR` 与 `B.IOS` 非法。

- 绑定流格式错误、维度缺失或为零、DataType 不受支持、布局不受支持或混合、源元素未定义、源几何不匹配，或参与运算的操作视图编码无效，会在效果之前引发 `Fault_TileLegality`。目标形状无法表示、`TSize` 不足、重命名目标不可用或 Tile 容量耗尽，会在发布之前引发 `Fault_TileAllocation`。

设计要点：最大值或最小值的浮点元素步骤通过浮点序键比较，架构为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3` 与 `E5M2` 定义了该序键。因此这里接受的每个浮点类型都能得到已定义的元素结果。

<!-- PTO-READER-BLOCK: tile-tcolexpandmin-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TCOLEXPANDMIN` 示例说明：完整形状的行 `[1, 5]` 与 `[7, 2]` 与广播第 0 行 `[3, 4]` 一起产生 `[[1, 4], [3, 2]]`。

对于有效区域为 7 x 60 且使用 `Zero` 填充的 8 x 64 `FP32` 源，目标有效区域为 7 x 60，因此计算 420 个元素，512 个坐标中有 92 个接收填充值。

同样的操作在宏形式下写作 `TCOLEXPANDMIN <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, T#2, ->T<2KB>`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLEXPANDMIN <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPANDMIN | TEPL | 0x05A | 26 | 2 | ExecuteTileExpand |

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
| source1 | persistent Local column broadcast source; only row zero supplies values through the BSTART operation view |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDMIN.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPANDMIN() => TileOperation
begin
    return TileOperation_TCOLEXPANDMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLEXPANDMIN, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDMIN.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLEXPANDMIN(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLEXPANDMIN(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_MIN,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TCOLEXPANDMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TCOLEXPANDMIN(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLEXPANDMIN(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_MIN,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For every valid destination element, compute typed min(source0[r,c], BroadcastTile[0,c]) at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TMIN typed operation.

## Legality

- TCOLEXPANDMIN is selected by the TEPL raw encoding carrier Mode 2 Function 26; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent column broadcast source with at least one valid row, and one newly allocated Local destination.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The BSTART DataType is both the source operation DataType and destination DataType. Each source backing DataType may differ only through an equal-width non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.
- The broadcast source has ValidRows >= 1 and ValidColumns equal to destination.ValidColumns; only BroadcastTile[0,c] supplies values, while later valid rows remain defined but ignored.
- The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.
- All source valid regions are fully defined and Numeric in the selected RowMajor, CUBE_M16, or CUBE_M32 layout. Full-shape and selected broadcast operation-view payloads must have valid encodings; ignored extra broadcast elements need definedness but are not encoding-validated.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.

## State effects

- For every valid destination element, compute typed min(source0[r,c], operation-view BroadcastTile[0,c]) at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TMIN typed operation.
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

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType or EXPDIF pair, unsupported or mixed layout, undefined source element, mismatched source geometry, or invalid consumed arithmetic/EXPDIF operation-view encoding raises Fault_TileLegality before effects. Ignored extra broadcast elements remain defined but are not encoding-validated.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Examples

- BSTART.SFU TCOLEXPANDMIN, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
