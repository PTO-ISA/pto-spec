<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl -->
# TROWEXPAND

**Normative ASL source:** `asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl`

Copy the selected row-broadcast element bit-for-bit into a new Local destination.

## Normative identity {#PTO-INST-TILE-TROWEXPAND}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowexpand-purpose role=purpose -->
## TROWEXPAND 的作用

`TROWEXPAND` 是由 `SFU` 引擎执行的 Tile 归约与扩展操作。它把 Local 源 Tile 的每个有效行取值广播到所有有效列：对每个目标坐标 `[r,c]` 复制 `BroadcastTile[r,BroadcastSlot]`。它由 `TEPL` Mode 2 Function 4（选择器 `0x044`）选中，没有独立 opcode。

设计要点：广播源是普通二维 Tile，其后面的有效列会被忽略。契约要求有效行数恰好等于目标且至少一个有效列，因此可以直接传入完整形状的 Tile，每个有效行只用所选槽位提供取值。

<!-- PTO-READER-BLOCK: tile-c-trowexpand-mechanism role=mechanism -->
## 操作机制

完整预检之后，`ExecuteTileExpand` 按递增行顺序、并在每行内按递增列顺序遍历目标有效矩形。每个坐标复制 `BroadcastTile[r,BroadcastSlot]` 的原始操作视图位；该复制不做转换、舍入、饱和、规范化，也不更新数值状态。

设计要点：该复制通过操作视图逐位进行。广播后备只有在等位宽、非打包载体视图下才允许与操作 DataType 不同，因此被复制的位按操作 DataType 重新解释。

<!-- PTO-READER-BLOCK: tile-c-trowexpand-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `source0` 是持久 Local 广播源，由终止 `B.IOT` 绑定一次。其有效行数必须等于目标，每个有效行只用所选槽位提供取值，其余有效列会被忽略，只有在不施加 ExecutionMask 时才必须已定义。

- `destination0` 是新分配的 Local Tile，DataType 为操作 DataType，几何由 `B.DIM` 推导；`LB0` 必需并提供非零 `ValidCol`，省略 `LB1` 选择 `ValidRow` 等于 1，省略 `LB2` 选择 `Col` 等于 `ValidCol`。其余物理坐标是填充坐标。

- 所有操作数使用同一布局，只有 `RowMajor`、`CUBE_M16` 与 `CUBE_M32` 是允许的布局。槽位在 `RowMajor` 下是逻辑第 0 列，在 `CUBE_M16` 与 `CUBE_M32` 下是由 `B.DATR.RMode` 选出的操作类型槽位。

- 各操作数共享同一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作，发生在描述符读取、分配、故障、状态或载荷效果之前。

设计要点：广播复制没有完整形状源，因此目标几何来自 `B.DIM` 推导的几何，而不是从第二个操作数复制。广播 Tile 只需在有效行数上一致，其有效列数可以大于 1。

设计要点：与归约不同，扩展接受共享的 Local CUBE ExecutionMask。非活动目标坐标取掩码的零值或合并值，而不是计算结果，也不贡献源读取与数值状态；带掩码时完整形状源必须与掩码的布局及两个有效范围一致。

<!-- PTO-READER-BLOCK: tile-c-trowexpand-effects role=effects -->
## 已定义性、填充与发布

目标作为一个整体发布：描述符、每个有效结果、已定义性、有效矩形之外的填充与累积的数值状态同时出现，被拒绝的执行不会发布其中任何一项。源的载荷在写入第一个目标元素前快照，因此合法别名读取旧的源值，源本身保持不变。

`ValidRow x ValidCol` 有效区域之外的物理目标坐标接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 会定义这些坐标；`Null` 使它们保持未定义。

设计要点：省略 `B.DATR` 选择 `Null`，而显式 `PadValue` 编码 `00` 选择 `Zero`。省略与编码零并不相同，因此要读取整个物理目标的程序必须请求 `Zero`、`Max` 或 `Min`。

<!-- PTO-READER-BLOCK: tile-c-trowexpand-constraints role=constraints -->
## 合法性、故障与顺序边界

可接受的操作类型为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 与 `U8`，`BSTART` DataType 同时是源操作 DataType 与目标 DataType。每个源后备只有在等位宽、非打包载体视图下才允许与它不同；原始位按操作 DataType 解释，不重新打标签，也不做数值转换。

- 恰好一条终止的 Local `B.IOT` 提供各操作数与一个新分配的 Local 目标；`B.IOR` 与 `B.IOS` 非法。

- 绑定流格式错误、维度缺失或为零、DataType 不受支持、布局不受支持或混合、源元素未定义、源几何不匹配，或参与运算的操作视图编码无效，会在效果之前引发 `Fault_TileLegality`。目标形状无法表示、`TSize` 不足、重命名目标不可用或 Tile 容量耗尽，会在发布之前引发 `Fault_TileAllocation`。

设计要点：广播复制完全不校验算术编码，因此被复制的元素不会因为是该类型的非规范编码而被拒绝；只检查已定义性、描述符、载体位宽与几何。

设计要点：对于 `CUBE_M32` 与 `CUBE_M16`，`B.DATR.RMode` 是无符号 `BroadcastByteOffset`，不是数值舍入选择子；`RowMajor` 要求它为零，偏移必须按元素对齐并落在同一个 `CELL` 分片内。

- 非法的 CUBE 字节偏移、对齐、`CELL` 槽位或有效列选择，会在源快照、目标分配或发布、数值状态与载荷效果之前引发 `Fault_TileLegality`；`PE_MASK=0000` 在严格无效果路径上跳过这一操作专属的选择子检查。

<!-- PTO-READER-BLOCK: tile-c-trowexpand-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

以一个小型 `TROWEXPAND` 示例说明：逻辑第 0 列为 `[10, 20]` 的广播源把两个有效目标行分别填成 `[10, 10]` 与 `[20, 20]`；即使其逻辑第 1 列为 `[99, 99]`，2 x 2 目标仍为 `[[10, 10], [20, 20]]`。

对于有效区域为 7 x 60 且使用 `Zero` 填充的 8 x 64 `FP32` 源，目标有效区域为 7 x 60，因此计算 420 个元素，512 个坐标中有 92 个接收填充值。

同样的操作在宏形式下写作 `TROWEXPAND <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, ->T<2KB>`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWEXPAND <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPAND | TEPL | 0x044 | 4 | 2 | ExecuteTileExpand |

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
| source0 | persistent Local row broadcast source; only the selected BroadcastSlot supplies values |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPAND() => TileOperation
begin
    return TileOperation_TROWEXPAND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWEXPAND, DataType
B.DATR Layout, RMode=BroadcastByteOffset for CUBE_M16/M32, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-expansion/TROWEXPAND.asl -->
```asl
pure func InstructionContractDataTypeLegal_TROWEXPAND(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWEXPAND(
    destination: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Row,
        destination,
        broadcast,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPAND() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPAND(
    destination: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPAND(
        destination,
        broadcast);
    ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Row,
        destination,
        broadcast,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For every valid destination element, copy BroadcastTile[r,BroadcastSlot] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.
- For CUBE_M32 and CUBE_M16, B.DATR.RMode[2:0] is the unsigned BroadcastByteOffset 0..7, not a numeric rounding selector. Omitted B.DATR selects offset zero. The offset is interpreted using the source operation DataType and selects a logical slot within the first CELL of the bound broadcast Tile; B.SUBVIEW selects a CELL/range before this in-CELL selection.

## Legality

- TROWEXPAND is selected by the TEPL raw encoding carrier Mode 2 Function 4; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent row broadcast source with at least one valid column and one newly allocated Local destination; no full-shape second source exists.
- The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.
- The destination DataType is the BSTART operation DataType. The broadcast source backing may differ only through an equal-width non-packed carrier view.
- The broadcast source has ValidRows equal to destination.ValidRows and ValidColumns >= 1. Without ExecutionMask its entire valid region remains required to be defined; with ExecutionMask, only the selected BroadcastTile[r,BroadcastSlot] for a row with an active destination coordinate must be defined. Other columns supply no broadcast value.
- The destination geometry is the B.DIM-derived geometry.
- Without ExecutionMask, the broadcast valid region remains fully defined. With ExecutionMask, only the selected BroadcastTile[r,BroadcastSlot] for each row with an active destination coordinate must be defined; an inactive row does not read or validate its selected element. COPY does not validate arithmetic encodings.
- Layout, PadValueOrByteId, and operation-specific RMode are applicable as encoded by the selected layout; RMode means BroadcastByteOffset only for CUBE_M16/M32 and must be zero for RowMajor. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- For CUBE_M32/CUBE_M16, the source-operation-typed BroadcastSlot is BroadcastByteOffset DIV ElementBytes. The offset must be less than the 4-byte M32 or 8-byte M16 per-row CELL slice, aligned to ElementBytes, and select a slot below both TileCubeCellColumns(Layout, SourceOperationDataType) and BroadcastTile.ValidColumns. The selector addresses only the first CELL of the bound broadcast Tile; B.SUBVIEW selects a later CELL/range when needed. RowMajor requires RMode zero.

## State effects

- For every valid destination element, copy the raw operation-view bits of BroadcastTile[r,BroadcastSlot] bit-for-bit.
- The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.
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

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported or mixed layout, undefined source element, or mismatched source geometry raises Fault_TileLegality before effects. COPY forms do not validate numeric encodings.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.
- After existing bundle and B.SUBVIEW preparation succeeds, an illegal CUBE byte offset, alignment, CELL slot, or valid-column selection raises Fault_TileLegality before source snapshot, destination allocation or publication, numeric status, or payload effects. PE_MASK=0000 keeps the strict no-effect path and skips this operation-specific selector check.

## Examples

- BSTART.SFU TROWEXPAND, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
