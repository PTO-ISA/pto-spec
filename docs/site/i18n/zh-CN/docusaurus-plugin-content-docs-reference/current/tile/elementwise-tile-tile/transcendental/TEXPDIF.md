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

`TEXPDIF` 在两个 Local 浮点 Tile 上逐元素计算 `exp(source0 - source1)`，并把结果写入一个新分配的 Local 目标 Tile。与 `TADD` 不同，目标类型可以比源类型更宽，且该操作在 `SFU` 引擎上执行。

设计要点：`TEXPDIF` 由 TEPL Mode 0 Function 29（选择器 `0x01D`）选中，没有独立 opcode。其规范头部写作 `BSTART.SFU TEXPDIF, SrcOperationType`。头部类型给出源操作类型；目标类型来自 `B.DATR`。

<!-- PTO-READER-BLOCK: tile-texpdif-mechanism role=mechanism -->
## 元素与 Tile 机制

完整预检之后，两个源都被快照，有效矩形 `ValidRow x ValidCol` 内的每个坐标独立计算。`source0` 始终是被减数，`source1` 是减数。两个源都覆盖完整的有效矩形；`TEXPDIF` 不会广播某一行或某一列。

对同类型对，该操作先在该类型中做带类型的减法，再做带类型的自然指数。两步都使用固定默认舍入，指数一步应用与 `TEXP` 相同的特殊输入表。

对混合类型对，即 `FP16` 或 `BF16` 源配 `FP32` 目标，两个输入先被精确加宽到 `FP32`。随后减法与指数都在 `FP32` 中进行。

设计要点：把 `FP16` 或 `BF16` 值加宽到 `FP32` 不会丢失任何信息，因此它被定义为一个解释步骤，而不是一次 `TCVT` 转换，也不会增加不精确状态。随后差值按 `FP32` 精度而不是 16 位精度舍入，再进入指数运算。

对每个元素，减法与指数的状态按位或合并。所有活动元素的状态再按位或累积，并在目标发布时记录。

<!-- PTO-READER-BLOCK: tile-texpdif-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是持久的被减数，按 `SrcOperationType` 解释。
- `source1` 是持久的减数，按 `SrcOperationType` 解释。
- `destination0` 是新分配的 Local Tile，其后备类型为目标类型 `DstDataType`。

一条终止 `B.IOT` 绑定全部三个 Tile，它们共享一个 `PE_MASK`。`PE_MASK=0000` 是严格无操作，发生在源描述符读取、目标分配、数值状态或载荷效果之前。

`DstDataType` 由 `B.DATR` 解析。省略 `B.DATR`，或把 `DataType` 字段编码为 `DTYPE_NONE`（代码 31），会使目标继承 `SrcOperationType`。编码为零的 `DataType` 选择 `FP64`，它不是合法的目标，因此会被拒绝。

设计要点：代码 0 已经表示 `FP64`，因此继承需要一个单独的哨兵值。使用 `DTYPE_NONE` 使“未请求目标类型”与真实的类型请求保持区分。

每个源的后备类型都可以独立地不同于 `SrcOperationType`，前提是两种类型都非打包、元素位宽相同且载体兼容。源位按 `SrcOperationType` 校验和解释，源描述符不会被重新标记类型。

<!-- PTO-READER-BLOCK: tile-texpdif-effects role=effects -->
## 发布、已定义性与填充

目标描述符、有效区域内的结果、填充、每个元素的已定义性以及累积的数值状态同时发布。被拒绝的指令束不发布任何目标载荷、填充、描述符或状态，两个源也保持不变。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入目标类型的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

由于两个源都在写入任何结果之前被快照，源与目标之间的合法别名会读取旧的源值。`TEXPDIF` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，且不贡献状态。

<!-- PTO-READER-BLOCK: tile-texpdif-constraints role=constraints -->
## 类型、布局与故障边界

合法的 `(SrcOperationType,DstDataType)` 对只有 `(FP16,FP16)`、`(BF16,BF16)`、`(FP32,FP32)`、`(FP16,FP32)` 与 `(BF16,FP32)`。其他任何类型对，包括变窄的类型对或整数类型，都会被拒绝。

布局为 `RowMajor`、`CUBE_M16` 或 `CUBE_M32`，三个操作数必须使用所选布局。`CUBE_N8`、Shared Tile 以及混合布局均非法。各操作数共享 `ValidRow` 与 `ValidCol`，但每个描述符的物理几何按其自身类型检查，因此 `FP32` 目标的物理大小可以不同于其 `FP16` 源。`B.DATR` 只接受 `Layout`、`DataType` 与 `PadValue`；非默认的 `CMode`、`RMode`、`Sat` 或 `Canonicalize` 均非法。

绑定格式错误或多余、出现 `B.IOR` 或 `B.IOS`、类型对非法、源载体为打包或位宽不同、源内容无效或未定义、布局或形状不匹配、维度错误时，会引发 `Fault_TileLegality`。目标形状无法表示或容量不足时，会引发 `Fault_TileAllocation`。两种故障都发生在任何目标效果之前。

<!-- PTO-READER-BLOCK: tile-texpdif-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

对混合类型对 `(FP16,FP32)`，被减数行 `[1.0, 2.0]` 与减数行 `[1.0, 1.0]` 被加宽到 `FP32`，得到差 `[0.0, 1.0]`。目标行为 `FP32` 的 `[1.0, e]`，其中 `exp(0)` 恰为 `1.0`，`e` 约为 2.71828。

对 `RowMajor` 中 8 x 64 的有效形状，每个 `FP16` 源占 8 x 64 x 2 = 1024 字节，而 `FP32` 目标需要 8 x 64 x 4 = 2048 字节。头部写作 `BSTART.SFU TEXPDIF, FP16`，`B.DATR` 选择目标 `DataType` `FP32`。同类型的 `FP32` 形式不需要 `B.DATR`，其宏形式写作 `TEXPDIF <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>`。
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
