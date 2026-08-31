<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl -->
# TMIN

**Normative ASL source:** `asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl`

Minimum corresponding Local Tile elements under typed integer and floating ordering.

## Normative identity {#PTO-INST-TILE-TMIN}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tmin-purpose role=purpose -->
## 用途

`TMIN` 按有符号、无符号或浮点排序选择两个 Local Tile 对应元素的最小值。

<!-- PTO-READER-BLOCK: tile-tmin-mechanism role=mechanism -->
## 执行机制

ASL DOC 契约通过该指令的选择器编码块载体选择 `TileHandler_ExecuteTileBinary`。

源快照之前，必须检查绑定模式、维度、DataType、行主序布局、源已定义性与编码、PE_MASK、目的容量和适用属性。

<!-- PTO-READER-BLOCK: tile-tmin-inputs-outputs role=inputs-outputs -->
## 操作数与描述符

`destination0` 是新 Local 目的地；`source0` 是左比较源；`source1` 是右比较源。

除非当前契约明确指出状态被消费或替换，否则源保持持久；只有完整预检后才发布目的描述符。

<!-- PTO-READER-BLOCK: tile-tmin-effects role=effects -->
## 发布与排序

每个有效坐标都按所选元素类型执行操作；目的地发布之前会快照全部源和私有 GPR 标量操作数。

有效载荷、选中的物理填充的已定义性、描述符和适用的粘滞数值标志原子发布；拒绝时没有架构效果。

<!-- PTO-READER-BLOCK: tile-tmin-constraints role=constraints -->
## 合法性、填充与故障

绑定格式错误、类型或布局不受支持、形状无效、被消费元素未定义、属性非法或目的容量不足时，会在源快照或发布之前拒绝操作。

`PE_MASK=0000` 是严格空操作，先于读取、分配、故障、数值状态、填充或描述符效果。分配失败触发所有者定义的 Tile 分配故障；其他被拒绝的绑定模式或值条件触发所有者定义的合法性、块控制或内存故障，且不产生部分效果。

<!-- PTO-READER-BLOCK: tile-tmin-example role=example -->
## 非规范契约草图

这是非规范契约模式草图；它用于组织字段和绑定关系，不声称可以直接汇编。

把 `BSTART.VEC TMIN, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP` 作为非规范绑定演练，再以下方生成契约确认精确维度、属性和故障行为。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TMIN <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMIN | TEPL | 0x00C | 12 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | left comparison source |
| source1 | right comparison source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl -->
```asl
readonly func InstructionContractOperation_TMIN() => TileOperation
begin
    return TileOperation_TMIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TMIN, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl -->
```asl
pure func InstructionContractDataTypeLegal_TMIN(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMIN(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MIN,
        destination,
        source_left,
        source_right);
end;

pure func InstructionContractFloatingValue_TMIN(
    data_type: TileDataType,
    source_left: Word,
    source_right: Word) => (Word, boolean)
begin
    assert InstructionContractDataTypeLegal_TMIN(data_type);
    assert TileDataTypeIsFloating(data_type);
    return TileFloatingMinMaxValue(
        TileBinary_MIN,
        data_type,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMIN(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MIN,
        destination,
        source_left,
        source_right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For floating TMIN, one NaN selects the numeric operand, two NaNs select canonical NaN, signaling NaN reports invalid, and mixed signed zeros select negative zero.

## Legality

- TMIN is BSTART.VEC Mode 0 Function 12 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.
- DataType is one of S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.
- Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Floating source encodings invalid for the selected operation reject before allocation or destination effects; PE_MASK zero is a strict no-op.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- Select the typed elementwise minimum for every valid coordinate.
- Signed integers use signed ordering, unsigned integers use unsigned ordering, and supported floating carriers use deterministic NaN and signed-zero rules.
- Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after complete legality and encoding preflight and before destination writes.
- Source aliasing and source-to-destination aliasing therefore observe pre-operation values.

## Exceptions

- Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, non-row-major layout, invalid source encoding, or invalid destination capacity raises Fault_TileLegality before effects.
- A signaling NaN reports the selected numeric profile invalid condition without changing the deterministic selected result.

## Examples

- BSTART.VEC TMIN, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
