<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl -->
# TROWEXPANDADD

**Normative ASL source:** `asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl`

Add a selected row-broadcast element to a full-shape source with exact typed semantics.

## Normative identity {#PTO-INST-TILE-TROWEXPANDADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-purpose role=purpose -->
## TROWEXPANDADD 的作用

`TROWEXPANDADD` 是由 `SFU` 引擎执行的 Tile 归约与扩展操作。它把完整形状源与每个有效行的一个广播值结合：对每个目标坐标 `[r,c]` 计算 `source0[r,c] + BroadcastTile[r,BroadcastSlot]`，因此广播 Tile 为每个有效行提供一个值。它由 `TEPL` Mode 2 Function 5（选择器 `0x045`）选中，没有独立 opcode。

设计要点：行扩展与对应的行归约在形状上互为逆操作：归约为每个有效行产生一个值，扩展则为每个有效行消费一个值并在每个有效列上复用，这也是广播操作数是 Tile 而不是标量的原因。

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-mechanism role=mechanism -->
## 操作机制

完整预检之后，`ExecuteTileExpand` 独立计算每个目标坐标 `[r,c]`，即 `source0[r,c] + BroadcastTile[r,BroadcastSlot]`，其中 `source0[r,c]` 始终是左操作数，`BroadcastTile[r,BroadcastSlot]` 始终是右操作数。整数结果停留在元素位宽上；浮点结果、异常值、带符号零行为与逐元素的数值状态标志与对应的 `TADD` 有类型操作完全一致。

设计要点：操作数顺序由架构规定而不是可配置的，每个元素的状态按位或合并为一次事务，并与结果一起发布。

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `source0` 是持久 Local 完整形状源。其逻辑有效几何与布局必须与目标一致。

- `source1` 是持久 Local 行广播源。只有 `BroadcastTile[r,BroadcastSlot]` 提供取值；后面的有效列会被忽略且不做编码校验，只有在不施加 ExecutionMask 时才必须已定义。

- `destination0` 是新分配的 Local Tile，DataType 为操作 DataType，几何由 `B.DIM` 推导；`LB0` 必需并提供非零 `ValidCol`，省略 `LB1` 选择 `ValidRow` 等于 1，省略 `LB2` 选择 `Col` 等于 `ValidCol`。其余物理坐标是填充坐标。

- 所有操作数使用同一布局，只有 `RowMajor`、`CUBE_M16` 与 `CUBE_M32` 是允许的布局。槽位在 `RowMajor` 下是逻辑第 0 列，在 `CUBE_M16` 与 `CUBE_M32` 下是由 `B.DATR.RMode` 选出的操作类型槽位。 64 位 CUBE 操作数要求 `CUBE_M32` double-CELL 映射；`CUBE_M16` 会拒绝。

- 各操作数共享同一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作，发生在描述符读取、分配、故障、状态或载荷效果之前。

设计要点：广播源只在被消费的位置检查。其有效行数必须与目标相同；不施加 ExecutionMask 时整个广播有效区域都必须已定义，施加 ExecutionMask 时只有至少含一个活动目标坐标的行所对应的 `BroadcastTile[r,BroadcastSlot]` 必须已定义。其余广播元素不做编码校验。

设计要点：与归约不同，扩展接受共享的 Local CUBE ExecutionMask。非活动目标坐标取掩码的零值或合并值，而不是计算结果，也不贡献源读取与数值状态；带掩码时完整形状源必须与掩码的布局及两个有效范围一致。

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-effects role=effects -->
## 已定义性、填充与发布

目标作为一个整体发布：描述符、每个有效结果、已定义性、有效矩形之外的填充与累积的数值状态同时出现，被拒绝的执行不会发布其中任何一项。两个源的载荷都在写入第一个目标元素前快照，因此合法别名读取旧的源值，源本身保持不变。

`ValidRow x ValidCol` 有效区域之外的物理目标坐标接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 会定义这些坐标；`Null` 使它们保持未定义。

设计要点：省略 `B.DATR` 选择 `Null`，而显式 `PadValue` 编码 `00` 选择 `Zero`。省略与编码零并不相同，因此要读取整个物理目标的程序必须请求 `Zero`、`Max` 或 `Min`。

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-constraints role=constraints -->
## 合法性、故障与顺序边界

可接受的操作类型为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 与 `U8`，`BSTART` DataType 同时是源操作 DataType 与目标 DataType。每个源后备只有在等位宽、非打包载体视图下才允许与它不同；原始位按操作 DataType 解释，不重新打标签，也不做数值转换。

- 恰好一条终止的 Local `B.IOT` 提供各操作数与一个新分配的 Local 目标；`B.IOR` 与 `B.IOS` 非法。

- 绑定流格式错误、维度缺失或为零、DataType 不受支持、布局不受支持或混合、源元素未定义、源几何不匹配，或参与运算的操作视图编码无效，会在效果之前引发 `Fault_TileLegality`。目标形状无法表示、`TSize` 不足、重命名目标不可用或 Tile 容量耗尽，会在发布之前引发 `Fault_TileAllocation`。

设计要点：合法性接受十六种类型，但浮点元素步骤会走到 `ScalarFPBinaryProfile`，它只为 `FP64`、`FP32`、`FP16` 与 `BF16` 定义。ASL 对 `TF32`、`HF32`、`E4M3` 与 `E5M2` 不给出元素结果，因此即使合法性接受这四种类型，这里也无法使用它们。

设计要点：对于 `CUBE_M32` 与 `CUBE_M16`，`B.DATR.RMode` 是无符号 `BroadcastByteOffset`，不是数值舍入选择子；`RowMajor` 要求它为零，偏移必须按元素对齐并落在同一个 `CELL` 分片内。

- 非法的 CUBE 字节偏移、对齐、`CELL` 槽位或有效列选择，会在源快照、目标分配或发布、数值状态与载荷效果之前引发 `Fault_TileLegality`；`PE_MASK=0000` 在严格无效果路径上跳过这一操作专属的选择子检查。

<!-- PTO-READER-BLOCK: tile-c-trowexpandadd-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

以一个小型 `TROWEXPANDADD` 示例说明：完整形状的行 `[1, 2]` 与 `[3, 4]` 加上广播第 0 列的取值 `[10, 20]` 产生 `[[11, 12], [23, 24]]`。

对于有效区域为 7 x 60 且使用 `Zero` 填充的 8 x 64 `FP32` 源，目标有效区域为 7 x 60，因此计算 420 个元素，512 个坐标中有 92 个接收填充值。

同样的操作在宏形式下写作 `TROWEXPANDADD <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, T#2, ->T<2KB>`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWEXPANDADD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDADD | TEPL | 0x045 | 5 | 2 | ExecuteTileExpand |

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
| source1 | persistent Local row broadcast source; only the selected BroadcastSlot supplies values through the BSTART operation view |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDADD() => TileOperation
begin
    return TileOperation_TROWEXPANDADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWEXPANDADD, DataType
B.DATR Layout, RMode=BroadcastByteOffset for CUBE_M16/M32, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-expansion/TROWEXPANDADD.asl -->
```asl
pure func InstructionContractDataTypeLegal_TROWEXPANDADD(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWEXPANDADD(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_ADD,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPANDADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPANDADD(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPANDADD(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_ADD,
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
- For every valid destination element, compute source0[r,c] + BroadcastTile[r,BroadcastSlot] at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TADD typed operation.
- For CUBE_M32 and CUBE_M16, B.DATR.RMode[2:0] is the unsigned BroadcastByteOffset 0..7, not a numeric rounding selector. Omitted B.DATR selects offset zero. The offset is interpreted using the source operation DataType and selects a logical slot within the first CELL of the bound broadcast Tile; B.SUBVIEW selects a CELL/range before this in-CELL selection.

## Legality

- TROWEXPANDADD is selected by the TEPL raw encoding carrier Mode 2 Function 5; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent row broadcast source with at least one valid column, and one newly allocated Local destination.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The BSTART DataType is both the source operation DataType and destination DataType. Each source backing DataType may differ only through an equal-width non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.
- The broadcast source has ValidRows equal to destination.ValidRows and ValidColumns >= 1. Without ExecutionMask its entire valid region remains required to be defined; with ExecutionMask, only the selected BroadcastTile[r,BroadcastSlot] for a row with an active destination coordinate must be defined. Other columns supply no broadcast value.
- The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.
- Without ExecutionMask, each source valid region remains fully defined. With ExecutionMask, only full-shape source coordinates consumed by active destinations and the selected broadcast element for each row with an active destination coordinate must be defined. Numeric encoding validation uses the source operation DataType for consumed full-shape elements and the selected broadcast element; unselected broadcast columns are not encoding-validated. Inactive rows contribute no source read, encoding validation, or numeric-status flags.
- Layout, PadValueOrByteId, and operation-specific RMode are applicable as encoded by the selected layout; RMode means BroadcastByteOffset only for CUBE_M16/M32 and must be zero for RowMajor. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- For CUBE_M32/CUBE_M16, the source-operation-typed BroadcastSlot is BroadcastByteOffset DIV ElementBytes. The offset must be less than the 4-byte lower-width M32 or 8-byte M16 per-row CELL slice (a b64 M32 group spans 8 bytes across the pair), aligned to ElementBytes, and select a slot below both TileCubeCellColumns(Layout, SourceOperationDataType) and BroadcastTile.ValidColumns. The selector addresses only the first logical CELL group of the bound broadcast Tile, including both planes for b64 M32; B.SUBVIEW selects a later CELL/range when needed. RowMajor requires RMode zero.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- For every valid destination element, compute source0[r,c] + operation-view BroadcastTile[r,BroadcastSlot] at the selected element width.
- Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TADD typed operation.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.
- Publish the complete renamed destination atomically after every element succeeds.
- For CUBE_M32/M16 row expansion, splat the source-operation-typed BroadcastTile[r,BroadcastSlot] selected by B.DATR.RMode; RowMajor continues to use BroadcastTile[r,BroadcastSlot].

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
- After existing bundle and B.SUBVIEW preparation succeeds, an illegal CUBE byte offset, alignment, CELL slot, or valid-column selection raises Fault_TileLegality before source snapshot, destination allocation or publication, numeric status, or payload effects. PE_MASK=0000 keeps the strict no-effect path and skips this operation-specific selector check.

## Examples

- BSTART.SFU TROWEXPANDADD, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
