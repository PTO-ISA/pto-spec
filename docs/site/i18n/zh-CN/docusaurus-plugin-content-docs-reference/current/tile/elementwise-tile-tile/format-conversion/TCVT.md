<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl -->
# TCVT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl`

Convert every valid source element to a separately typed and laid-out Local destination.

## Normative identity {#PTO-INST-TILE-TCVT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-tcvt-purpose role=purpose -->
## TCVT 的作用

`TCVT` 是一条由 `VEC` 执行、通过选择器编码的 Tile 操作。它把每个有效逻辑元素转换为独立选择的目标类型和布局；当前指令契约拥有精确的指令束形式和发布边界。

<!-- PTO-READER-BLOCK: tile-tcvt-mechanism role=mechanism -->
## 元素与 Tile 机制

所有描述符与操作数检查成功后，所属 ASL 处理函数把每个有效逻辑元素转换为独立选择的目标类型和布局。当前契约允许别名时，源载荷会在目标写入前完成快照。

处理函数使用解析后的有效区域，不把物理填充区当作输入数据。操作专属的数据类型、布局、舍入、饱和与配置档钩子仍由可执行定义拥有。

<!-- PTO-READER-BLOCK: tile-tcvt-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `destination0` 的精确契约角色是“采用独立类型与布局的新 Local 目标”。
- `source0` 的精确契约角色是“持久 Local 源”。
- `numeric_control` 的精确契约角色是“已解析的舍入与饱和控制”。

操作读取的每个源坐标都必须在目标发布前处于已定义状态。
`PE_MASK=0000` 是严格无操作，在描述符、分配、载荷、数值状态或内存效果之前即结束。

<!-- PTO-READER-BLOCK: tile-tcvt-effects role=effects -->
## 发布、已定义性与填充

只有完整预检后才发布目标可见状态；契约规定原子发布时，载荷、描述符、已定义性、填充和状态同时可见。

有效矩形之外的物理坐标遵循契约选择的填充规则；适用时，`Null` 填充保持未定义。

该操作不产生 GM 内存效果；描述符、载荷、已定义性、填充和数值状态变化仅限于当前契约列出的项目。

<!-- PTO-READER-BLOCK: tile-tcvt-constraints role=constraints -->
## 类型、布局与故障边界

源采用 BSTART `DataType`；目标采用显式 B.DATR `DataType`，未显式给出时继承源类型。所有已分配类型都可接受，但必须满足精确的类型组合、布局、规范化与 E8M0 配置档规则。

下方生成的合法性与异常章节是数据类型组合、布局、维度、容量、已定义性、填充控制、配置档行为和故障类别的权威说明。合法性或分配失败发生在任何部分架构效果之前。

<!-- PTO-READER-BLOCK: tile-tcvt-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `TCVT` 示例说明：精确 FP32 值 `2.0` 转换为 FP16 后仍为 `2.0`。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TCVT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCVT | TEPL | 0x01B | 27 | 0 | TCVT |

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

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | new typed and laid-out Local destination |
| source0 | persistent Local source |
| numeric_control | resolved rounding and saturation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl -->
```asl
readonly func InstructionContractOperation_TCVT() => TileOperation
begin
    return TileOperation_TCVT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCVT, SrcDataType
B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional)
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional)
B.DIM LB2=Col (optional)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl -->
```asl
pure func InstructionContractDataTypeLegal_TCVT(
    data_type: TileDataType) => boolean
begin
    // TileDataType has exactly the twenty-five assigned architectural values.
    // Reserved five-bit encodings never enter this semantic type.
    return TRUE;
end;

pure func InstructionContractDestinationDataType_TCVT(
    source_type: TileDataType,
    data_type_field_present: boolean,
    data_type_code: bits(5)) => TileDataType
begin
    if data_type_field_present && BundleDataTypeConcrete(data_type_code) then
        return BundleTileDataType(data_type_code);
    end;
    return source_type;
end;

pure func InstructionContractDefaultRounding_TCVT(
    source_type: TileDataType,
    destination_type: TileDataType) => NumericRoundingMode
begin
    if TileDataTypeIsFloating(source_type) &&
       TileDataTypeIsInteger(destination_type) then
        return NumericRound_RTZ;
    end;
    return NumericRound_RNE;
end;

func InstructionContractExecute_TCVT(
    destination: TileIndex,
    source: TileIndex,
    control: NumericExecutionControl)
begin
    assert TileOperandsLegal_TCVT(destination, source, control);
    TCVT(destination, source, control);
end;

readonly func InstructionContractHandler_TCVT() => TileSemanticHandler
begin
    return TileHandler_TCVT;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The BSTART DataType is SrcDataType. Omitted B.DATR or DTYPE_NONE inherits SrcDataType as DstDataType; an explicitly encoded DataType zero selects FP64.
- LB0 is required and supplies ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol. Every present dimension must be nonzero.
- RMode zero selects RTZ for floating-to-integer conversion and RNE for every other conversion that requires rounding. Sat zero disables saturation and Canonicalize zero selects an ordinary public source.
- Omitted B.DATR selects Layout=NORM and PadValue=Null. Explicit PadValue codes 00, 01, 10, and 11 select Zero, Max, Min, and Null.
- For an E8M0 destination, RMode rounds the base-two exponent. Exact powers of two are exact; Sat selects finite endpoint clamp versus 0xFF for finite range overflow or underflow.

## Legality

- TCVT is selected only by VEC Mode 0 Function 27 and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one source and one newly allocated destination. B.IOR, B.IOS, a second source, and a second binding are illegal.
- For ordinary layouts, source and destination have equal Row, Col, ValidRow, and ValidCol. For a CUBE_M16 or CUBE_M32 source, the destination preserves the same CUBE layout and ValidRow/ValidCol, while Row, Col, CELL count, capacity, and packing independently match the destination DataType.
- Every assigned Tile DataType is legal. Reserved five-bit DataType codes reject before effects; HiF4X2 is TCVT-only.
- Every assigned Layout code has executable indexing. The source descriptor matches the transform source layout and the destination descriptor matches its target layout; CUBE_M16 and CUBE_M32 conversions retain the source layout.
- A private CUBE source requires Canonicalize=1 and Layout=NORM. A CUBE_M16 or CUBE_M32 matrix source requires Canonicalize=0 and Layout=NORM; its destination remains a Matrix CUBE representation. An ordinary source requires Canonicalize=0.
- The source valid region is fully defined and contains valid encodings. PE_MASK=0000 is a strict no-op before schema, descriptor, allocation, or payload checks.
- Under the named hardware profile, an E8M0 destination accepts exactly FP16, BF16, or FP32 sources. Every other source-to-E8M0 pair rejects before destination allocation.
- The BSTART DataType is the source operation interpretation, not necessarily the ordinary source backing DataType. An ordinary non-packed source may differ only by same-width backing type; Matrix/CUBE sources retain exact backing/source-operation type equality. The destination backing type is the resolved B.DATR destination type.

## State effects

- Snapshot the persistent source, convert every valid logical element under the resolved rounding and saturation controls, and write the corresponding logical coordinate in the destination layout.
- Define or undefine every physical padding coordinate according to PadValue and publish the destination; ordinary conversions use the public representation, while CUBE_M16 and CUBE_M32 conversions retain the Matrix CUBE representation.
- The source may alias the destination; execution observes the complete pre-execution source snapshot.
- For a supported E8M0 conversion, map the rounded base-two exponent to code exponent+127 and accumulate exact NV/UF/OF/NX status before atomic publication.
- For FP64, FP32, FP16, E4M3, S64, S32, S16, S8, U64, U32, U16, and U8 source/destination pairs, TCVT uses the same deterministic conversion result and flags as the scalar conversion family.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Complete schema, type, logical geometry, layout, canonicalization, capacity, encoding, and definedness preflight precedes the source snapshot and destination allocation.
- Converted payload, numeric status, padding definedness, public representation state, and destination descriptor publish atomically.

## Exceptions

- Malformed bindings, missing or zero dimensions, type, shape, capacity, layout, canonicalization, encoding, or definedness mismatch raises Fault_TileLegality before destination allocation or payload effects.
- Reserved selector, DataType, or Layout encodings raise the corresponding instruction or Tile legality fault before effects.
- CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.
- For E8M0, zero, negative values, and NaNs produce 0xFF with NV. Positive infinity follows the overflow rule. Finite values below 2^-127 or above 2^127 produce 0xFF when Sat=0 or clamp to 0x00/0xFE when Sat=1, with UF/OF plus NX.

## Examples

- BSTART.VEC TCVT, SrcDataType; B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
