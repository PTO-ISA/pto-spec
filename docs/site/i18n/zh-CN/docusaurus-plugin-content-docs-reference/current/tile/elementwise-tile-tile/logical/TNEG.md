<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
# TNEG

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TNEG.asl`

Typed elementwise arithmetic negation over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TNEG}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tneg-purpose role=purpose -->
## 用途

`TNEG` 对一个 Local Tile 源执行类型化逐元素算术取负。

<!-- PTO-READER-BLOCK: tile-tneg-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_ExecuteTileUnary`。

源快照之前，必须检查绑定模式、维度、DataType、行主序布局、源已定义性与编码、PE_MASK、目的容量和适用属性。

<!-- PTO-READER-BLOCK: tile-tneg-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是新 Local 目的地；`source0` 是取负源。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tneg-effects role=effects -->
## 发布与排序

每个有效坐标都按所选元素类型执行操作；目的地发布之前会快照全部源和私有 GPR 标量操作数。

有效载荷、选中的物理填充的已定义性、描述符和适用的粘滞数值标志原子发布；拒绝时没有架构效果。

<!-- PTO-READER-BLOCK: tile-tneg-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

`PE_MASK=0000` 是严格空操作，先于读取、分配、故障、数值状态、填充或描述符效果。分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tneg-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.VEC TNEG, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TNEG <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TNEG | TEPL | 0x011 | 17 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | negation source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
```asl
readonly func InstructionContractOperation_TNEG() => TileOperation
begin
    return TileOperation_TNEG;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TNEG, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TNEG.asl -->
```asl
pure func InstructionContractDataTypeLegal_TNEG(
    data_type: TileDataType) => boolean
begin
    return TileTNegDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TNEG(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_NEG,
        destination,
        source);
end;

pure func InstructionContractValue_TNEG(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_NEG,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TNEG() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TNEG(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_NEG, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Integer negation is zero minus the source modulo the selected element width, including unsigned types. Floating negation toggles only the sign bit, preserving zeros, infinities, NaN class, and NaN payload without reporting invalid solely for TNEG.

## Legality

- TNEG is BSTART.VEC Mode 0 Function 17 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, S16, S8, FP32, FP16, or BF16.
- Source and destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; the source valid region is fully defined.
- Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.

## State effects

- For every valid coordinate, negate modulo the selected integer width or toggle only the floating sign bit according to DataType.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.
- Source-to-destination aliasing therefore observes the complete pre-operation source payload.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-row-major layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.
- This operation introduces no memory fault and reports no floating invalid condition solely from its value transform.

## Examples

- BSTART.VEC TNEG, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
