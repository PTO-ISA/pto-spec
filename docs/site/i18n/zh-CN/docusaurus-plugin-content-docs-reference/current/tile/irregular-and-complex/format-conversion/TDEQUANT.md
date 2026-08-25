<!-- GENERATED FROM: asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl -->
# TDEQUANT

**Normative ASL source:** `asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl`

Affine-dequantize a Local S8 or U8 Tile into a new Local FP32 Tile.

## Normative identity {#PTO-INST-TILE-TDEQUANT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tdequant-purpose role=purpose -->
## TDEQUANT 的作用

`TDEQUANT` 是一条由 `SFU` 执行、通过选择器编码的 Tile 操作。它对每个有效 S8 或 U8 源元素计算 FP32 `(q - zero_point) * multiplier`；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tdequant-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数对每个有效 S8 或 U8 源元素计算 FP32 `(q - zero_point) * multiplier`。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tdequant-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“新分配的 FP32 目标”。
- `source0` 的精确契约角色是“持久 S8 或 U8 源”。
- `scalar0` 的精确契约角色是“正有限 FP32 乘数”。
- `scalar1` 的精确契约角色是“采用源类型的整数零点”。
- `numeric_control` 的精确契约角色是“舍入控制”。

参与操作的源与目标描述符采用当前契约规定的行优先布局和形状关系。
操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-tdequant-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tdequant-constraints role=constraints -->
## 类型、布局与故障边界

源类型只能是 `S8` 或 `U8`；新分配的目标类型只能是 `FP32`。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tdequant-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TDEQUANT` 示例说明：源值 `q=3`、零点 `1` 与乘数 `0.5` 产生 FP32 值 `1.0`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TDEQUANT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDEQUANT | TEPL | 0x06B | 11 | 3 | TDEQUANT |

## Encoding class

- **Class:** `selector-encoded-block-operation`
- **Standalone opcode:** `no`

This operation has no standalone opcode.

## Field value dispositions

### BSTART.DataType (`PTO-FIELD-BLOCK-DATATYPE`)

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
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
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
| 15 | reserved | future extension |
| 16 | assigned | S64 |
| 17 | assigned | S32 |
| 18 | assigned | S16 |
| 19 | assigned | S8 |
| 20 | assigned | S4X2 |
| 21 | reserved | future extension |
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
| destination0 | new FP32 destination |
| source0 | persistent S8 or U8 source |
| scalar0 | positive finite FP32 multiplier |
| scalar1 | source-typed integer zero point |
| numeric_control | rounding |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl -->
```asl
readonly func InstructionContractOperation_TDEQUANT() => TileOperation
begin
    return TileOperation_TDEQUANT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TDEQUANT, S8|U8
B.DATR FP32, RMode
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col (optional, default ValidCol)
B.IOR MultiplierFP32, ZeroPoint (optional; omission selects 1.0 and 0)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/format-conversion/TDEQUANT.asl -->
```asl
pure func InstructionContractDataTypesLegal_TDEQUANT(
    source_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return (source_type == TileDataType_S8 ||
            source_type == TileDataType_U8) &&
           destination_type == TileDataType_FP32;
end;

pure func InstructionContractDefaultMultiplier_TDEQUANT() => Word
begin
    return Zeros{PTO_XLEN} + 0x3f800000;
end;

pure func InstructionContractDefaultZeroPoint_TDEQUANT() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractScaleLegal_TDEQUANT(scale: Word) => boolean
begin
    return TileQuantizationScaleLegal(scale);
end;

pure func InstructionContractZeroPointLegal_TDEQUANT(
    zero_point: Word,
    source_type: TileDataType) => boolean
begin
    return TileQuantizationZeroPointLegal(
        zero_point,
        source_type);
end;

readonly func InstructionContractOperandsLegal_TDEQUANT(
    destination: TileIndex,
    source: TileIndex,
    multiplier: Word,
    zero_point: Word,
    control: NumericExecutionControl) => boolean
begin
    return TileOperandsLegal_TDEQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
end;

readonly func InstructionContractHandler_TDEQUANT() => TileSemanticHandler
begin
    return TileHandler_TDEQUANT;
end;

func InstructionContractExecute_TDEQUANT(
    destination: TileIndex,
    source: TileIndex,
    multiplier: Word,
    zero_point: Word,
    control: NumericExecutionControl)
begin
    assert InstructionContractOperandsLegal_TDEQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
    TDEQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART DataType is exactly S8 or U8 and B.DATR is mandatory with destination DataType FP32.
- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one and omitted LB2 selects Col equal to ValidCol.
- Omitted B.IOR selects the raw FP32 multiplier encoding 0x3f800000 and zero point zero. A present all-zero B.IOR selects multiplier zero and is illegal.
- RMode zero selects RNE. Sat, Canonicalize, Layout, CMode, and PadValue are inapplicable and must be zero. Physical padding is always Null.

## Legality

- TDEQUANT is selected by the TEPL encoding carrier Mode 3 Function 11, canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one S8 or U8 source and one new FP32 destination. B.IOS, a second B.IOT, a second source, and a second destination are illegal.
- B.DATR is mandatory and permits only DataType and RMode. DataType is exactly FP32; Sat is zero.
- The source valid region and physical Col match LB1, LB0, and LB2 respectively. Source and destination are row-major and their capacities independently match their DataTypes.
- A present B.IOR consumes RegSrc0 as a positive, finite, nonzero raw FP32 multiplier and RegSrc1 as a canonically encoded zero point in the source integer type. RegSrc2 and RegDst are zero.
- The complete integer source valid region is defined and contains valid encodings. All participating masks are equal; PE_MASK zero is a strict no-op.

## State effects

- For every valid integer element q, compute FP32(q minus ZeroPoint) multiplied by MultiplierFP32 and round once using RMode.
- Every physical destination coordinate outside ValidRow by ValidCol is undefined Null padding.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, fields, type, shape, capacity, source-definedness, source-encoding, multiplier, zero-point, mask, destination-name, and allocation preflight precedes the source snapshot.
- The source persists. The result payload, sticky numeric flags, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none.

## Exceptions

- Missing or surplus bindings, B.IOS, absent or invalid B.DATR, unsupported types, non-row-major layout, malformed dimensions, undefined or invalid source elements, non-finite, negative, or zero multiplier, or an out-of-range zero point raises Fault_TileLegality before allocation or payload effects.
- An unrepresentable destination shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before allocation.
- PE_MASK zero is a strict no-op before schema, GPR, descriptor, allocation, numeric-status, padding, or payload effects.

## Examples

- BSTART.SFU TDEQUANT, S8; B.DATR FP32, RNE; B.DIM LB0=16; B.IOT T1, mask=1111, <last>, ->T0<1>; BSTOP
