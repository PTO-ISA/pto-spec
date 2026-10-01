<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl -->
# TCOLSUM

**Normative ASL source:** `asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl`

Reduce each valid column to its sum with exact typed row-order semantics.

## Normative identity {#PTO-INST-TILE-TCOLSUM}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcolsum-purpose role=purpose -->
## TCOLSUM 的作用

`TCOLSUM` 是由 `SFU` 引擎执行的 Tile 归约与扩展操作。它把单个 Local 源 Tile 的每个有效列归约为一个元素。它由 `TEPL` Mode 2 Function 16（选择器 `0x050`）选中，没有独立 opcode。

设计要点：归约轴属于操作身份，而不是指令束字段：`TEPL` 把 `TileAxis_Column`（列轴）固定为常量实参，目标形状又以一个等于 1 的逻辑维度重申它，因此方向只凭助记符即可确定。

<!-- PTO-READER-BLOCK: tile-tcolsum-mechanism role=mechanism -->
## 元素与 Tile 机制

预检检查指令束模式、源描述符、源已定义性、源编码、目标容量与操作数模式。只有全部通过后，`ExecuteTileReduction` 才遍历每个有效列：累加器从该类型的零编码开始，该列的每个元素都被加进去。

每一步都是严格递增行顺序上的 `TADD` 有类型运算。整数结果只保留精确结果的元素位宽位，浮点结果遵循所选类型的数值配置档。

设计要点：`TCOLSUM` 是有序折叠，而不是归约树。重新结合会改变浮点舍入结果，因此 ASL 固定了元素的合并顺序。

<!-- PTO-READER-BLOCK: tile-tcolsum-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是持久 Local 源 Tile。其有效区域的每个坐标都参与，其存储后备类型只有在等位宽、非打包载体视图下才允许与操作类型不同。

- `destination0` 是新分配的 Local Tile，DataType 为操作 DataType，逻辑形状为 一个有效行乘 60 个有效列，每个有效列一个结果；其余物理坐标是填充坐标，对于 `RowMajor`，物理行数由目标容量推导。

- 目标使用源的布局，只有 `RowMajor`、`CUBE_M16` 与 `CUBE_M32` 是允许的布局。

- 各操作数共享同一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作，发生在描述符读取、分配、故障、状态或载荷效果之前。

设计要点：归约不接受共享的 Local CUBE ExecutionMask。只要存在有效的掩码状态——无论是指令束中编码的还是注入模型的——操作数检查就会失败，指令束因此故障，而不是只归约一个子集；每个有效源坐标都必须已定义、编码有效并参与归约。

<!-- PTO-READER-BLOCK: tile-tcolsum-effects role=effects -->
## 发布、已定义性与填充

目标作为一个整体变为可见：描述符、结果、已定义性、有效结果矩形之外的填充与累积的数值状态同时发布，被拒绝的执行不会发布其中任何一项。源保持不变，该操作没有 GM 内存效果。

`1 x 60` 有效区域之外的物理目标坐标接收所选 `PadValue`。`Zero`、`Max` 与 `Min` 会定义这些坐标；`Null` 使它们保持未定义。

设计要点：省略 `B.DATR` 选择 `Null`，而显式 `PadValue` 编码 `00` 选择 `Zero`。省略与编码零并不相同，因此要读取整个物理目标的程序必须请求 `Zero`、`Max` 或 `Min`。

<!-- PTO-READER-BLOCK: tile-tcolsum-constraints role=constraints -->
## 类型、布局与故障边界

可接受的操作类型为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16` 与 `U8`。目标 DataType 等于操作类型。源可以使用位宽相同、非打包的其他后备类型，但 `RCPE6M2` 绝不能作为归约后备；活动的指令束必须从 `BSTART` 解析出操作 DataType，否则拒绝。

- 恰好一条终止的 Local `B.IOT` 提供源与新目标，因此 `B.IOR`、`B.IOS`、第二条 `B.IOT`、非终止绑定，以及把目标命名为源的写法都非法。

- 绑定流格式错误、维度缺失或为零、DataType 不受支持、源布局不合法/混合/不匹配、源元素未定义或源编码无效，会在效果之前引发 `Fault_TileLegality`；结果形状、`TSize`、重命名或容量失败会在发布之前引发 `Fault_TileAllocation`。

设计要点：合法性接受十六种类型，但该浮点折叠步骤会走到 `ScalarFPBinaryProfile`，它只为 `FP64`、`FP32`、`FP16` 与 `BF16` 定义。ASL 对 `TF32`、`HF32`、`E4M3` 与 `E5M2` 不给出元素结果，因此即使合法性接受这四种类型，这里也无法使用它们。

<!-- PTO-READER-BLOCK: tile-tcolsum-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TCOLSUM` 示例说明：列数据 `[[1, 4], [3, 2]]` 归约为 `[4, 6]`：左列折叠 `0 + 1 + 3`，右列折叠 `0 + 4 + 2`。

对于有效区域为 7 x 60 且使用 `Zero` 填充的 8 x 64 `FP32` 源，遍历访问 60 个有效列，每个执行 7 个合并步骤，因此目标得到 60 个结果，位于由 `2KB` `TSize` 推导出的 8 x 64 形状内的 `1 x 60` 有效区域中，其中 512 个坐标里有 452 个是 `Zero` 定义的填充坐标。

同样的操作在宏形式下写作 `TCOLSUM <Row=8, Col=64, ValidRow=7, ValidCol=60, FP32, Zero>, T#1, ->T<2KB>`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLSUM <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLSUM | TEPL | 0x050 | 16 | 2 | ExecuteTileReduction |

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
| destination0 | new Local operation-type numeric destination |
| source0 | persistent Local numeric source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl -->
```asl
readonly func InstructionContractOperation_TCOLSUM() => TileOperation
begin
    return TileOperation_TCOLSUM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLSUM, DataType
B.DATR Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-reduction/TCOLSUM.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCOLSUM(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLSUM(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileReduction(
        TileReduction_SUM,
        TileAxis_Column,
        destination,
        source);
end;

readonly func InstructionContractHandler_TCOLSUM() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;

func InstructionContractExecute_TCOLSUM(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLSUM(
        destination,
        source);
    ExecuteTileReduction(
        TileReduction_SUM,
        TileAxis_Column,
        destination,
        source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.
- Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TCOLSUM computes a typed increasing-row left fold from zero using TADD; the scan order is architectural and tree reassociation is not permitted.

## Legality

- TCOLSUM is selected by the TEPL raw encoding carrier Mode 2 Function 16; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.
- Exactly one terminating Local B.IOT supplies one persistent Local source and one newly allocated Local destination. B.IOR, B.IOS, a second B.IOT, or a nonterminating binding is illegal.
- The operation DataType selected by BSTART is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- The destination DataType equals the selected operation DataType.
- The source is a fully defined persistent numeric Tile with a legal descriptor in the selected RowMajor, CUBE_M16, or CUBE_M32 layout whose ValidRow, ValidCol, and physical Col exactly match the B.DIM-derived source geometry; its stored backing DataType MAY differ from the operation DataType only when the unchanged TileCarrierWidthCompatible relation admits equal-width, non-packed interpretation. RCPE6M2 MUST NOT be a reduction backing. Every valid source coordinate MUST be defined and encoding-valid under the operation DataType. All valid source coordinates are checked and included in the reduction; Local CUBE ExecutionMask is unsupported and MUST reject before effects, including when mask state is injected directly into the model. For a cross-type view, backing encodings are not independently validated. The source descriptor, backing DataType, and payload persist unchanged without retagging or numeric conversion. The source capacity is checked by generic allocation and the reduction operation imposes no additional 2048-byte ceiling.
- The destination has logical ValidRow equal to one and ValidCol equal to source.ValidCol. For RowMajor, Rows equals DerivedTileRows(DstCapacity, source physical Columns, DstDataType) and Columns equals source physical Columns. For CUBE_M16/M32, Rows equals source Rows and Columns equals align_up(Dst.ValidColumns, Dst CellCols), where Dst CellCols is computed from destination DataType.
- Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. Source and destination share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects.
- An active bundle MUST resolve the operation DataType from BSTART or reject; a direct semantic call with no active bundle uses source backing DataType as the operation-type fallback.

## State effects

- For each valid column, compute a typed increasing-row left fold from zero using TADD.
- Write the operation-typed reduction value without widening integer arithmetic or reassociating the fold.
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

- BSTART.SFU TCOLSUM, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
