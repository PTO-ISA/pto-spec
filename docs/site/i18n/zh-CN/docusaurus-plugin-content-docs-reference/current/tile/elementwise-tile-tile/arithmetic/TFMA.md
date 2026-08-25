<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
# TFMA

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl`

Fused typed elementwise multiply-add over three Local Tile sources.

## Normative identity {#PTO-INST-TILE-TFMA}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tfma-purpose role=purpose -->
## 用途

`TFMA` 对三个 Local Tile 源执行融合的逐元素乘加。

<!-- PTO-READER-BLOCK: tile-tfma-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_TFMA`。

源快照之前，必须检查绑定模式、维度、DataType、行主序布局、源已定义性与编码、PE_MASK、目的容量和适用属性。

<!-- PTO-READER-BLOCK: tile-tfma-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是新重命名 Local 目的地；`source0` 是左乘数 Local 源；`source1` 是右乘数 Local 源；`source2` 是融合加数 Local 源。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tfma-effects role=effects -->
## 发布与排序

每个有效坐标都按所选元素类型执行操作；目的地发布之前会快照全部源和私有 GPR 标量操作数。

有效载荷、选中的物理填充的已定义性、描述符和适用的粘滞数值标志原子发布；拒绝时没有架构效果。

<!-- PTO-READER-BLOCK: tile-tfma-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

`PE_MASK=0000` 是严格空操作，先于读取、分配、故障、数值状态、填充或描述符效果。分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tfma-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.VEC TFMA, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK; B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TFMA <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TFMA | TEPL | 0x01C | 28 | 0 | TFMA |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new renamed Local destination |
| source0 | left multiplicand Local source |
| source1 | right multiplicand Local source |
| source2 | fused addend Local source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
```asl
readonly func InstructionContractOperation_TFMA() => TileOperation
begin
    return TileOperation_TFMA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TFMA, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK
B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl -->
```asl
pure func InstructionContractDataTypeLegal_TFMA(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex) => boolean
begin
    return TileOperandsLegal_TFMA(
        destination,
        source_left,
        source_right,
        addend);
end;

func InstructionContractValue_TFMA(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    return TileFixedFusedMultiplyAddValue(
        data_type,
        left,
        right,
        addend);
end;

readonly func InstructionContractHandler_TFMA() => TileSemanticHandler
begin
    return TileHandler_TFMA;
end;

func InstructionContractExecute_TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex)
begin
    TFMA(
        destination,
        source_left,
        source_right,
        addend);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol. Physical rows derive exactly from TSize, Col, and DataType.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- TFMA uses the selected numeric profile's fixed/default arithmetic rounding. It does not consume encoded RMode, Sat, or Canonicalize fields.

## Legality

- TFMA is selected by the TEPL encoding carrier Mode 0 Function 28, canonically assembled with BSTART.VEC, and has no standalone opcode.
- Exactly two ordered Local B.IOT bindings are required: the first supplies two multiplicands without a destination or last marker; the second supplies the addend and one new destination and terminates the sequence.
- DataType is exactly one of FP16, FP32, or BF16.
- All three sources and the destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; every valid source element is defined.
- Only B.DATR PadValueOrByteId is applicable. Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- B.IOR and B.IOS are illegal. All participating B.IOT masks are equal; PE_MASK zero is a strict no-op before source reads, allocation, arithmetic, flags, padding, or descriptor effects.

## State effects

- For floating DataTypes, each valid destination element is one fused left multiplied by right plus addend operation with no rounded intermediate product and one final profile rounding.
- For signed and unsigned integer DataTypes, each valid destination element is left multiplied by right plus addend modulo the element width; carrier bits above that width are zero.
- The selected PadValue defines or leaves undefined the physical destination region outside ValidRow by ValidCol without changing any source descriptor or source payload.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, dimension, DataType, layout, source-definedness, source-encoding, PE_MASK, destination-name, and capacity preflight precedes all three source snapshots.
- Duplicate sources and any source-to-destination alias observe complete pre-operation source payloads. Sources persist after both successful and rejected blocks.
- The complete result payload, selected padding definedness, sticky numeric flags, and renamed destination descriptor publish as one architectural operation; rejection has no architectural effect.

## Exceptions

- Malformed or surplus bindings, B.IOR or B.IOS, unequal masks, missing or invalid dimensions, unsupported DataType, non-row-major layout, undefined source elements, mismatched descriptors, or invalid floating encodings raise Fault_TileLegality before effects.
- An unrepresentable destination shape, unavailable renamed destination, insufficient per-PE TSize, or exhausted architectural Tile capacity raises Fault_TileAllocation before allocation.
- A signaling NaN, zero multiplied by infinity, infinity multiplied by zero, or an infinite product added to an opposite-signed infinity produces a quiet NaN and records floating invalid without a synchronous trap.

## Examples

- BSTART.VEC TFMA, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK; B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
