<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl -->
# TEXPDIF

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl`

Compute natural exp(src0-src1) elementwise over two full-shape Local Tiles.

## Normative identity {#PTO-INST-TILE-TEXPDIF}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-texpdif-purpose role=purpose -->
## TEXPDIF 的作用

`TEXPDIF` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它在每个有效坐标计算 `source0 - source1` 的自然指数，其中 `source0` 是被减数，`source1` 是减数；该操作不广播。

<!-- PTO-READER-BLOCK: tile-texpdif-mechanism role=mechanism -->
## 元素与 Tile 机制

所有指令束、描述符和操作数检查成功后，同类型组合先执行带类型减法，再执行带类型自然指数。混合的 `FP16` 到 `FP32` 及 `BF16` 到 `FP32` 组合会先精确拓宽两个输入，再执行 FP32 减法和自然指数；该拓宽不是 TCVT，也不会增加转换不精确状态。

结果计算前会完整快照两个源 Tile。当合法的同宽别名同时命名源和重命名目标时，执行因此表现为读旧值、写新值。

<!-- PTO-READER-BLOCK: tile-texpdif-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“新分配的 Local DstDataType 数值目标”。
- `source0` 的精确契约角色是“持久 Local SrcOperationType 被减数”。
- `source1` 的精确契约角色是“持久 Local SrcOperationType 减数”。

源和目标共享所选布局以及逻辑 `ValidRow * ValidCol` 区域，而每个描述符的物理几何形状按各自后备类型或目标类型检查。仅当满足当前契约的同宽、非 packed、载体兼容规则时，源后备类型才可不同于 `SrcOperationType`。

<!-- PTO-READER-BLOCK: tile-texpdif-effects role=effects -->
## 发布、状态与填充

对于每个有效元素，处理函数累积减法与指数状态，再对整个有效区域的状态求 OR。两个源 Tile 保持不变。

所选 `PadValue` 应用于有效结果矩形之外。完整预检后，目标载荷、描述符、已定义性、填充和累积数值状态原子发布。

该操作不产生 GM 内存效果。`PE_MASK=0000` 是严格无操作，在读取源描述符、分配目标、更新数值状态或产生载荷效果之前即结束。

<!-- PTO-READER-BLOCK: tile-texpdif-constraints role=constraints -->
## 类型、布局与故障边界

精确合法的 `(SrcOperationType,DstDataType)` 组合是 `(FP16,FP16)`、`(BF16,BF16)`、`(FP32,FP32)`、`(FP16,FP32)` 和 `(BF16,FP32)`。合法布局是 `RowMajor`、`CUBE_M16` 和 `CUBE_M32`；混合布局以及其他任何类型组合或布局都会被拒绝。

一个终止型 Local `B.IOT` 提供两个有序持久源和一个新目标。绑定格式错误、维度或源内容无效、描述符不兼容以及不受支持的控制会在产生效果前引发生成的合法性故障；目标形状、容量、名称或 Tile 耗尽则会在发布前引发分配故障。

<!-- PTO-READER-BLOCK: tile-texpdif-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

对于两个源元素均为正零的合法同类型坐标，减法产生零，自然指数随后在目标坐标产生同类型正一。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TEXPDIF <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TEXPDIF | TEPL | 0x01D | 29 | 0 | ExecuteTileExpdif |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### B.DATR.DataType (`PTO-FIELD-BLOCK-DATATYPE`)

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
| destination0 | new Local DstDataType numeric destination |
| source0 | persistent Local SrcOperationType minuend |
| source1 | persistent Local SrcOperationType subtrahend |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl -->
```asl
readonly func InstructionContractOperation_TEXPDIF() => TileOperation
begin
    return TileOperation_TEXPDIF;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TEXPDIF, SrcOperationType
B.DATR Layout, DataType, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TEXPDIF.asl -->
```asl
pure func InstructionContractDataTypeLegal_TEXPDIF(
    source_operation_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return TileExpdifTypePairLegal(
        source_operation_type, destination_type);
end;

readonly func InstructionContractOperandsLegal_TEXPDIF(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpdif(
        destination, source0, source1);
end;

readonly func InstructionContractHandler_TEXPDIF() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpdif;
end;

func InstructionContractExecute_TEXPDIF(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex)
begin
    ExecuteTileExpdif(destination, source0, source1);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero and legal under the selected descriptor geometry.
- Omitted B.DATR selects Layout=NORM (RowMajor), DstDataType=SrcOperationType, and PadValue=Null. When B.DATR is present, DataType=DTYPE_NONE inherits SrcOperationType and a concrete DataType selects DstDataType; encoded DataType zero selects FP64 and is not absence.

## Legality

- TEXPDIF is TEPL Mode 0 Function 29 (selector 0x01D) on SFU; 0x01C remains TFMA and 0x01E..0x01F remain reserved.
- Exactly one terminating Local B.IOT supplies two ordered persistent Local numeric sources and one newly allocated Local numeric destination. B.IOR, B.IOS, additional bindings, and shared operands are illegal.
- The exact legal (SrcOperationType,DstDataType) pairs are (FP16,FP16), (BF16,BF16), (FP32,FP32), (FP16,FP32), and (BF16,FP32). All other pairs reject.
- Each source backing type may differ independently from SrcOperationType only when both types are non-packed, have equal element width, and TileCarrierWidthCompatible is true. Source payloads are validated and interpreted as SrcOperationType without retagging the source descriptors.
- The result for every valid coordinate is natural exp(src0-src1), with source0 as minuend and source1 as subtrahend. TEXPDIF does not broadcast.
- Same-type pairs perform typed SUB followed by typed natural EXP. Mixed FP16/BF16-to-FP32 pairs exactly widen both inputs to FP32 before FP32 SUB and FP32 natural EXP; widening is not TCVT and adds no conversion-inexact status.
- Only RowMajor, CUBE_M16, and CUBE_M32 are legal. CUBE_N8, Shared, unsupported layouts, and mixed operand layouts reject. Sources and destination share the selected layout and logical ValidRow x ValidCol; each descriptor's physical geometry is checked using its own backing/destination type.
- B.DATR Layout, DataType, and PadValueOrByteId are the only applicable nonzero fields. CMode, RMode, Sat, Canonicalize, and unrelated fields are illegal.
- PE_MASK=0000 is a strict no-op before source descriptor reads, destination allocation, numeric status, or payload effects.

## State effects

- For every valid logical coordinate compute exp(src0-src1) using the shared typed EXPDIF numeric owner and the selected natural-EXP profile.
- Mixed FP16/BF16-to-FP32 results use exact widening before FP32 subtraction; the destination has independently derived FP32 geometry and capacity.
- Apply the selected PadValue outside the valid result rectangle, then atomically publish destination state and accumulated numeric status.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- For nonzero participation, decode and validate commands, dimensions, type pair, source descriptors/carriers/definedness/encodings, destination size/capacity/name allocation, and destination geometry before result publication.
- Snapshot both complete sources before computing results. Legal same-width source/destination aliasing observes read-old/write-new behavior; source Tiles remain unchanged.
- For each valid element, OR SUB and EXP status; OR status across elements. Apply destination padding and publish the full destination descriptor, payload, definedness, and accumulated status atomically.

## Exceptions

- Malformed Local bindings, B.IOR or B.IOS presence, extra bindings, unsupported or reserved type pairs, packed or width-changing source carriers, invalid source encodings, undefined source contents, layout or logical-shape mismatch, invalid dimensions, or illegal source descriptors raise Fault_TileLegality before effects.
- An unrepresentable destination shape, insufficient TSize/capacity, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before publication.
- Rejection publishes no destination payload, padding, descriptor, or numeric status.

## Examples

- BSTART.SFU TEXPDIF, SrcOperationType; B.DATR Layout, DataType, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
