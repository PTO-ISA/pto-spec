<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TABS.asl -->
# TABS

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TABS.asl`

Typed elementwise absolute value over one Local Tile source.

## Normative identity {#PTO-INST-TILE-TABS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tabs-purpose role=purpose -->
## TABS 的作用

`TABS` 是一条由 `VEC` 执行、通过选择器编码的 Tile 操作。它对每个有效源坐标独立执行有类型绝对值运算；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tabs-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数对每个有效源坐标独立执行有类型绝对值运算。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tabs-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“新分配的 Local 目标”。
- `source0` 的精确契约角色是“绝对值运算源”。

参与操作的源与目标描述符采用当前契约规定的行优先布局和形状关系。
操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-tabs-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tabs-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tabs-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TABS` 示例说明：有效元素 `[-2, 3]` 变为 `[2, 3]`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TABS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TABS | TEPL | 0x00F | 15 | 0 | ExecuteTileUnary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | absolute-value source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TABS.asl -->
```asl
readonly func InstructionContractOperation_TABS() => TileOperation
begin
    return TileOperation_TABS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TABS, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TABS.asl -->
```asl
pure func InstructionContractDataTypeLegal_TABS(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TABS(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_ABS,
        destination,
        source);
end;

pure func InstructionContractValue_TABS(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_ABS,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TABS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TABS(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_ABS, destination, source);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- Signed integers use modulo-width absolute value, including retaining the minimum signed bit pattern; unsigned integers are unchanged. Floating values clear only the sign bit, including zeros, infinities, and NaN payloads, without reporting invalid solely for TABS.

## Legality

- TABS is BSTART.VEC Mode 0 Function 15 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- Source and destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; the source valid region is fully defined.
- Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.
- Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.

## State effects

- For every valid coordinate, compute signed modulo-width absolute value, unsigned identity, or floating sign-bit clearing according to DataType.
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

- BSTART.VEC TABS, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
