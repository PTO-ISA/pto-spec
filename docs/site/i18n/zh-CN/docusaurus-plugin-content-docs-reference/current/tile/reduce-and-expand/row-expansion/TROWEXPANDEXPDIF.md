<!-- GENERATED FROM: asl/tile/reduce-and-expand/row-expansion/TROWEXPANDEXPDIF.asl -->
# TROWEXPANDEXPDIF

**Normative ASL source:** `asl/tile/reduce-and-expand/row-expansion/TROWEXPANDEXPDIF.asl`

Exponentiate the source-type difference using a selected row-broadcast element.

## Normative identity {#PTO-INST-TILE-TROWEXPANDEXPDIF}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-trowexpandexpdif-purpose role=purpose -->
## TROWEXPANDEXPDIF 的作用

`TROWEXPANDEXPDIF` 是由 `SFU` 引擎执行的 Tile 归约与扩展操作。它把完整形状源与每个有效行的一个广播值结合：对每个目标坐标 `[r,c]` 计算 `exp(source0[r,c] - BroadcastTile[r,BroadcastSlot])`，因此广播 Tile 为每个有效行提供一个值。它由 `TEPL` Mode 2 Function 11（选择器 `0x04B`）选中，没有独立 opcode。

设计要点：行扩展与对应的行归约在形状上互为逆操作：归约为每个有效行产生一个值，扩展则为每个有效行消费一个值并在每个有效列上复用，这也是广播操作数是 Tile 而不是标量的原因。

<!-- PTO-READER-BLOCK: tile-c-trowexpandexpdif-mechanism role=mechanism -->
## 操作机制

完整预检之后，`ExecuteTileExpand` 把每个目标坐标 `[r,c]` 计算为 `exp(source0[r,c] - BroadcastTile[r,BroadcastSlot])`，指数，两个操作数都按 `SrcDataType` 解释。同类型对在该类型上做减法和指数；`FP16` 或 `BF16` 到 `FP32` 的混合对先把两个值精确加宽到 `FP32`。

设计要点：`FP16` 或 `BF16` 到 `FP32` 的加宽是精确的，因此它是解释步骤而不是转换，不产生转换状态。差值只在 `FP32` 精度上舍入一次，两个阶段的状态按位 OR 合并为一次事务。

<!-- PTO-READER-BLOCK: tile-c-trowexpandexpdif-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `source0` 是持久 Local 完整形状源。其逻辑有效几何与布局必须与目标一致。

- `source1` 是持久 Local 行广播源。只有 `BroadcastTile[r,BroadcastSlot]` 提供取值；后面的有效列会被忽略且不做编码校验，只有在不施加 ExecutionMask 时才必须已定义。

- `destination0` 是新分配的 Local Tile，其后备类型为 `DstDataType`；不引入目标别名，也不对源描述符重新打标签。

- 所有操作数使用同一布局，只有 `RowMajor`、`CUBE_M16` 与 `CUBE_M32` 是允许的布局。槽位在 `RowMajor` 下是逻辑第 0 列，在 `CUBE_M16` 与 `CUBE_M32` 下是由 `B.DATR.RMode` 选出的操作类型槽位。

- 各操作数共享同一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作，发生在描述符读取、分配、故障、状态或载荷效果之前。

设计要点：广播源只在被消费的位置检查。其有效行数必须与目标相同；不施加 ExecutionMask 时整个广播有效区域都必须已定义，施加 ExecutionMask 时只有至少含一个活动目标坐标的行所对应的 `BroadcastTile[r,BroadcastSlot]` 必须已定义。其余广播元素不做编码校验。

设计要点：与归约不同，扩展接受共享的 Local CUBE ExecutionMask。非活动目标坐标取掩码的零值或合并值，而不是计算结果，也不贡献源读取与数值状态；带掩码时完整形状源必须与掩码的布局及两个有效范围一致。

<!-- PTO-READER-BLOCK: tile-c-trowexpandexpdif-effects role=effects -->
## 已定义性、填充与发布

目标作为一个整体发布：描述符、每个有效结果、已定义性、有效矩形之外的填充与累积的数值状态同时出现，被拒绝的执行不会发布其中任何一项。两个源的载荷都在写入第一个目标元素前快照，因此合法别名读取旧的源值，源本身保持不变。

`ValidRow x ValidCol` 有效区域之外的物理目标坐标接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 会定义这些坐标；`Null` 使它们保持未定义。

设计要点：省略 `B.DATR` 选择 `Null`，而显式 `PadValue` 编码 `00` 选择 `Zero`。省略与编码零并不相同，因此要读取整个物理目标的程序必须请求 `Zero`、`Max` 或 `Min`。

<!-- PTO-READER-BLOCK: tile-c-trowexpandexpdif-constraints role=constraints -->
## 合法性、故障与顺序边界

`TROWEXPANDEXPDIF` 与 `TCOLEXPANDEXPDIF` 接受的 `(SrcDataType,DstDataType)` 对恰好是 `(FP64,FP64)`、`(FP32,FP32)`、`(FP16,FP16)`、`(BF16,BF16)`、`(FP16,FP32)` 与 `(BF16,FP32)`。`BSTART` 选择 `SrcDataType`；省略 `B.DATR` 或使用 `DTYPE_NONE` 会使 `DstDataType` 继承它。

设计要点：编码为 0 的 `DataType` 表示 `FP64`，永远不表示缺失，因此继承需要单独的 `DTYPE_NONE` 哨兵；想要源类型的程序必须省略 `B.DATR` 或有意编码 `DTYPE_NONE`。

- 恰好一条终止的 Local `B.IOT` 提供各操作数与一个新分配的 Local 目标；`B.IOR` 与 `B.IOS` 非法。

- 绑定流格式错误、维度缺失或为零、DataType 不受支持、布局不受支持或混合、源元素未定义、源几何不匹配，或参与运算的操作视图编码无效，会在效果之前引发 `Fault_TileLegality`。目标形状无法表示、`TSize` 不足、重命名目标不可用或 Tile 容量耗尽，会在发布之前引发 `Fault_TileAllocation`。

设计要点：指数阶段接受 `FP64`、`FP32`、`FP16` 与 `BF16`，每个合法对都映射到这些可执行类型。64 位 CUBE 形式要求 `CUBE_M32`。

设计要点：对于 `CUBE_M32` 与 `CUBE_M16`，`B.DATR.RMode` 是无符号 `BroadcastByteOffset`，不是数值舍入选择子；`RowMajor` 要求它为零，偏移必须按元素对齐并落在同一个 `CELL` 分片内。

- 非法的 CUBE 字节偏移、对齐、`CELL` 槽位或有效列选择，会在源快照、目标分配或发布、数值状态与载荷效果之前引发 `Fault_TileLegality`；`PE_MASK=0000` 在严格无效果路径上跳过这一操作专属的选择子检查。

<!-- PTO-READER-BLOCK: tile-c-trowexpandexpdif-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

以一个小型 `TROWEXPANDEXPDIF` 示例说明：完整形状的行 `[1, 2]` 与 `[3, 4]` 减去广播第 0 列的取值 `[1, 2]` 得到差值 `[[0, 1], [1, 2]]`，因此目标为 `[[1, e], [e, e^2]]`。

对于有效区域为 7 x 60 且使用 `Zero` 填充的 8 x 64 `FP32` 源，目标有效区域为 7 x 60，因此计算 420 个元素，512 个坐标中有 92 个接收填充值。

同样的操作在宏形式下写作 `TROWEXPANDEXPDIF <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, T#2, ->T<2KB>`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TROWEXPANDEXPDIF <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDEXPDIF | TEPL | 0x04B | 11 | 2 | ExecuteTileExpand |

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

### DataType (`PTO-FIELD-BLOCK-DATATYPE`)

Selects the Tile element data type carried by Block data attributes and typed Block starts.

**Encoded zero:** Code zero selects FP64; zero never means absent, inherited, NONE, or NULL.

| Code | Disposition | Meaning |
| ---: | --- | --- |
| 0 | assigned | FP64 |
| 1 | assigned | FP32 |
| 2 | assigned | TF32 |
| 3 | assigned | HF32 |
| 4 | assigned | FP16 |
| 5 | assigned | BF16 |
| 6 | assigned | HiF8 |
| 7 | assigned | E4M3 |
| 8 | assigned | E5M2 |
| 9 | assigned | E3M2 |
| 10 | assigned | E2M3 |
| 11 | assigned | E2M1X2 |
| 12 | assigned | E1M2X2 |
| 13 | assigned | E8M0 |
| 14 | assigned | HiF4X2 |
| 15 | assigned | E6M2 |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | assigned | RCPE6M2 |
| 22 | reserved | future extension |
| 23 | reserved | future extension |
| 24 | assigned | U64 |
| 25 | assigned | U32 |
| 26 | assigned | U16 |
| 27 | assigned | U8 |
| 28 | assigned | U4X2 |
| 29 | reserved | future extension |
| 30 | reserved | future extension |
| 31 | reserved | future extension |

**Reserved-value behavior:** Reserved values are held for future extension and reject before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local DstDataType destination |
| source0 | persistent Local full-shape numeric source |
| source1 | persistent Local row broadcast source interpreted through SrcDataType; only the selected BroadcastSlot supplies values |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/row-expansion/TROWEXPANDEXPDIF.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDEXPDIF() => TileOperation
begin
    return TileOperation_TROWEXPANDEXPDIF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TROWEXPANDEXPDIF, DataType
B.DATR Layout, DataType, RMode=BroadcastByteOffset, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/row-expansion/TROWEXPANDEXPDIF.asl -->
```asl
pure func InstructionContractDataTypeLegal_TROWEXPANDEXPDIF(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_FP32;
end;

readonly func InstructionContractOperandsLegal_TROWEXPANDEXPDIF(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPANDEXPDIF() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPANDEXPDIF(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPANDEXPDIF(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects DstDataType=SrcDataType and PadValue=Null. When B.DATR is present, DTYPE_NONE inherits SrcDataType, a concrete DataType selects DstDataType, and encoded DataType zero selects FP64 and is never absence. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For CUBE_M32 and CUBE_M16, B.DATR.RMode[2:0] is the unsigned BroadcastByteOffset 0..7, not a numeric rounding selector. Omitted B.DATR selects offset zero. The offset is interpreted using the source operation DataType and selects a logical slot within the first CELL of the bound broadcast Tile; B.SUBVIEW selects a CELL/range before this in-CELL selection.

## Legality

- TROWEXPANDEXPDIF and TCOLEXPANDEXPDIF accept exactly (FP64,FP64), (FP16,FP16), (BF16,BF16), (FP32,FP32), (FP16,FP32), and (BF16,FP32) as (SrcDataType,DstDataType) pairs.
- BSTART DataType selects SrcDataType; omitted B.DATR or explicit DataType=DTYPE_NONE selects DstDataType=SrcDataType, while a concrete B.DATR DataType selects DstDataType. Each source backing may differ from SrcDataType only through an equal-width non-packed carrier view; raw bits are interpreted as SrcDataType without retagging or numeric conversion.
- Mixed FP16/BF16 to FP32 widens the operation-view source bits exactly to FP32 before FP32 subtraction and FP32 exponential. Same-type pairs retain their selected type.
- The destination is newly allocated with DstDataType; no destination alias or source descriptor retag is introduced.
- The broadcast source has ValidRows equal to destination.ValidRows and ValidColumns >= 1. Without ExecutionMask its entire valid region remains required to be defined; with ExecutionMask, only the selected BroadcastTile[r,BroadcastSlot] for a row with an active destination coordinate must be defined. Other columns supply no broadcast value.
- The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.
- Without ExecutionMask, each source valid region remains fully defined. With ExecutionMask, only full-shape source coordinates consumed by active destinations and the selected broadcast element for each row with an active destination coordinate must be defined. Numeric encoding validation uses the source operation DataType for consumed full-shape elements and the selected broadcast element; unselected broadcast columns are not encoding-validated. Inactive rows contribute no source read, encoding validation, or numeric-status flags.
- Layout, PadValueOrByteId, DataType, and operation-specific RMode are applicable as encoded by the selected layout; RMode means BroadcastByteOffset only for CUBE_M16/M32 and must be zero for RowMajor. B.IOR and B.IOS are illegal.
- All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- For CUBE_M32/CUBE_M16, the source-operation-typed BroadcastSlot is BroadcastByteOffset DIV ElementBytes. The offset must be less than the 4-byte lower-width M32 or 8-byte M16 per-row CELL slice (a b64 M32 group spans 8 bytes across the pair), aligned to ElementBytes, and select a slot below both TileCubeCellColumns(Layout, SourceOperationDataType) and BroadcastTile.ValidColumns. The selector addresses only the first logical CELL group of the bound broadcast Tile, including both planes for b64 M32; B.SUBVIEW selects a later CELL/range when needed. RowMajor requires RMode zero.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.
- FP64 source and FP64 destination form an accepted same-type pair; mixed FP64 type pairs are not added.

## State effects

- For each destination [r,c], interpret source0[r,c] and BroadcastTile[r,BroadcastSlot] as SrcDataType. For mixed FP16/BF16 to FP32 pairs, widen both exactly to FP32, then subtract and exponentiate at FP32; same-type pairs retain the existing sequence.
- The subtraction and exponential stages apply in sequence and their numeric-status flags are accumulated into one transaction.
- Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.
- Publish the complete renamed destination atomically after every element succeeds.
- For CUBE_M32/M16 row expansion, splat the source-operation-typed BroadcastTile[r,BroadcastSlot] selected by B.DATR.RMode; RowMajor continues to use BroadcastTile[r,BroadcastSlot].

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, attribute, dimension, source/destination type-pair, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.
- All source payloads are snapshotted before result construction; sources persist and same-type legal aliases use read-old/write-new behavior.
- Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType or EXPDIF pair, unsupported or mixed layout, undefined source element, mismatched source geometry, or invalid consumed arithmetic/EXPDIF operation-view encoding raises Fault_TileLegality before effects. Ignored extra broadcast elements remain defined but are not encoding-validated.
- An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.
- All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none.
- After existing bundle and B.SUBVIEW preparation succeeds, an illegal CUBE byte offset, alignment, CELL slot, or valid-column selection raises Fault_TileLegality before source snapshot, destination allocation or publication, numeric status, or payload effects. PE_MASK=0000 keeps the strict no-effect path and skips this operation-specific selector check.

## Examples

- BSTART.SFU TROWEXPANDEXPDIF, SrcDataType; B.DATR Layout, DataType, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
