<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
# TDIV

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TDIV.asl`

Divide corresponding Local Tile elements under the selected numeric profile.

## Normative identity {#PTO-INST-TILE-TDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tdiv-purpose role=purpose -->
## TDIV 的作用

`TDIV` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它按照所选整数或浮点解释，把相应分子元素除以分母元素；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tdiv-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数按照所选整数或浮点解释，把相应分子元素除以分母元素。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tdiv-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“新分配的 Local 目标”。
- `source0` 的精确契约角色是“有序分子”。
- `source1` 的精确契约角色是“有序分母”。

参与操作的源与目标描述符采用当前契约规定的行优先布局和形状关系。
操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-tdiv-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tdiv-constraints role=constraints -->
## 类型、布局与故障边界

可接受的数据类型集合为 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`、`S64`、`S32`、`S16`、`S8`、`U64`、`U32`、`U16`、`U8`。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tdiv-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TDIV` 示例说明：分子 `8` 与分母 `2` 产生商 `4`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TDIV <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDIV | TEPL | 0x003 | 3 | 0 | ExecuteTileBinary |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new Local destination |
| source0 | ordered numerator |
| source1 | ordered denominator |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
```asl
readonly func InstructionContractOperation_TDIV() => TileOperation
begin
    return TileOperation_TDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TDIV, DataType
B.DATR PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TDIV.asl -->
```asl
pure func InstructionContractDataTypeLegal_TDIV(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;

readonly func InstructionContractHandler_TDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TDIV(
    destination: TileIndex,
    numerator: TileIndex,
    denominator: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_DIV,
        destination,
        numerator,
        denominator);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LB0 is required and nonzero; omitted LB1 selects ValidRow=1 and omitted LB2 selects Col=ValidCol.
- Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- The numeric profile owns fixed rounding, floating exceptional values, and floating positive or negative zero division.

## Legality

- TDIV retains TEPL carrier Mode 0 Function 3 but is canonically classified as SFU.
- Exactly one terminating Local B.IOT supplies ordered numerator and denominator sources plus one new Local destination; B.IOR and B.IOS are illegal and PE_MASK zero is a strict no-op.
- The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.
- Only B.DATR PadValueOrByteId is applicable.
- The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits.

## State effects

- Signed integers use signed division, unsigned integers use unsigned division, and floating values use the selected floating division profile.
- The valid quotient and selected physical padding publish atomically; rejection leaves descriptor, payload, and allocation state unchanged.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Both source payloads are snapshotted after all legality and integer-zero checks, so aliasing is read-before-write.

## Exceptions

- An integer zero in the valid denominator rectangle raises Fault_TileLegality before source snapshots, allocation publication, or destination effects; denominator padding is not read.
- Malformed bindings, unsupported types, undefined inputs, mismatched descriptors, or invalid capacity reject before effects; floating zero is handled by the selected numeric profile.

## Examples

- BSTART.SFU TDIV, S64; B.DIM LB0=ValidCol; B.IOT Numerator, Denominator, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
