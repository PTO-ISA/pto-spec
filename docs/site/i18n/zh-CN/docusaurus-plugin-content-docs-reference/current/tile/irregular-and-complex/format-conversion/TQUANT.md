<!-- GENERATED FROM: asl/tile/irregular-and-complex/format-conversion/TQUANT.asl -->
# TQUANT

**Normative ASL source:** `asl/tile/irregular-and-complex/format-conversion/TQUANT.asl`

Affine-quantize a Local FP32 Tile into a new Local S8 or U8 Tile.

## Normative identity {#PTO-INST-TILE-TQUANT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-c-tquant-purpose role=purpose -->
## TQUANT 的作用

`TQUANT` 对 Local FP32 Tile 执行仿射量化，生成新的 Local S8 或 U8 Tile。

<!-- PTO-READER-BLOCK: tile-c-tquant-mechanism role=mechanism -->
## 操作机制

对每个有效 FP32 值 `x`，计算 `x * multiplier + zero_point`，再应用选定舍入模式。

启用饱和时结果钳制到 S8/U8 范围；否则按目标宽度取模转换。

浮点结果与元素状态遵循当前具名数值配置档；可移植契约拥有选择、形状、发布与故障顺序。

<!-- PTO-READER-BLOCK: tile-c-tquant-inputs-outputs role=inputs-outputs -->
## 操作数、形状与类型

- `destination0` 标识新分配的目的 Tile。

- `source0` 提供持久源 Tile。

- `scalar0` 提供正有限 FP32 乘数。

- `scalar1` 提供按目标 DataType 编码的整数零点。

- `numeric_control` 提供舍入与饱和控制。

- 封闭的适用 DataType 集合为 `FP32`、`S8`、`U8`。

- 除非该助记符显式选择其他允许布局，数据 Tile 使用行主序布局。

- `LB0`、`LB1`、`LB2` 按该助记符契约补全有效形状与物理形状；所有必需有效范围都必须非零。

<!-- PTO-READER-BLOCK: tile-c-tquant-effects role=effects -->
## 已定义性、填充与发布

所有源描述符与载荷都会在目标发布前完成验证和快照。

完整目标载荷、描述符、已定义性、填充状态与适用数值状态会原子发布；拒绝路径不发布任何部分。

有效矩形外的每个物理坐标都是未定义 Null 填充；该操作不允许选择其他填充值。

源 Tile 在成功执行后保持不变。

<!-- PTO-READER-BLOCK: tile-c-tquant-constraints role=constraints -->
## 合法性、故障与顺序边界

完整绑定模式、维度、DataType、布局、源已定义性、数值编码、目标容量与分配都会在效果前预检。

合法性或分配检查失败会引发相应 Tile 故障，不留下部分目标、状态或内存效果。

`PE_MASK=0000` 是严格无操作，发生在操作数读取、分配、故障、数值状态或载荷效果之前。

<!-- PTO-READER-BLOCK: tile-c-tquant-example role=example -->
## 非规范示例

下面的示例只帮助理解当前 ASL 绑定契约，并不是第二份指令定义。

`TQUANT <bundle operands>` 先完成完整预检与源快照，再原子发布助记符定义的结果与填充状态。
<!-- SUPPLEMENTARY-END -->

## Classification and execution engine

- **Instruction class:** `irregular-and-complex`
- **Execution engine:** `SFU`

## Assembly

```asm
TQUANT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TQUANT | TEPL | 0x06A | 10 | 3 | TQUANT |

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
| destination0 | new S8 or U8 destination |
| source0 | persistent FP32 source |
| scalar0 | positive finite FP32 multiplier |
| scalar1 | destination-typed integer zero point |
| numeric_control | rounding and saturation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/irregular-and-complex/format-conversion/TQUANT.asl -->
```asl
readonly func InstructionContractOperation_TQUANT() => TileOperation
begin
    return TileOperation_TQUANT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TQUANT, FP32
B.DATR S8|U8, RMode, Sat
B.DIM LB0=ValidCol
B.DIM LB1=ValidRow (optional, default 1)
B.DIM LB2=Col (optional, default ValidCol)
B.IOR MultiplierFP32, ZeroPoint (optional; omission selects 1.0 and 0)
B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/irregular-and-complex/format-conversion/TQUANT.asl -->
```asl
pure func InstructionContractDataTypesLegal_TQUANT(
    source_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return source_type == TileDataType_FP32 &&
           (destination_type == TileDataType_S8 ||
            destination_type == TileDataType_U8);
end;

pure func InstructionContractDefaultMultiplier_TQUANT() => Word
begin
    return Zeros{PTO_XLEN} + 0x3f800000;
end;

pure func InstructionContractDefaultZeroPoint_TQUANT() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractScaleLegal_TQUANT(scale: Word) => boolean
begin
    return TileQuantizationScaleLegal(scale);
end;

pure func InstructionContractZeroPointLegal_TQUANT(
    zero_point: Word,
    destination_type: TileDataType) => boolean
begin
    return TileQuantizationZeroPointLegal(
        zero_point,
        destination_type);
end;

readonly func InstructionContractOperandsLegal_TQUANT(
    destination: TileIndex,
    source: TileIndex,
    multiplier: Word,
    zero_point: Word,
    control: NumericExecutionControl) => boolean
begin
    return TileOperandsLegal_TQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
end;

readonly func InstructionContractHandler_TQUANT() => TileSemanticHandler
begin
    return TileHandler_TQUANT;
end;

func InstructionContractExecute_TQUANT(
    destination: TileIndex,
    source: TileIndex,
    multiplier: Word,
    zero_point: Word,
    control: NumericExecutionControl)
begin
    assert InstructionContractOperandsLegal_TQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
    TQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART DataType is exactly FP32 and B.DATR is mandatory with destination DataType S8 or U8.
- LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one and omitted LB2 selects Col equal to ValidCol.
- Omitted B.IOR selects the raw FP32 multiplier encoding 0x3f800000 and zero point zero. A present all-zero B.IOR selects multiplier zero and is illegal.
- RMode zero selects RNE. Sat zero selects modulo destination-width conversion; Sat one clamps to the destination range.
- Canonicalize, Layout, CMode, and PadValue are inapplicable and must be zero. Physical padding is always Null.

## Legality

- TQUANT is selected by the TEPL encoding carrier Mode 3 Function 10, canonically assembled with BSTART.SFU, and has no standalone opcode.
- Exactly one terminating Local B.IOT supplies one FP32 source and one new S8 or U8 destination. B.IOS, a second B.IOT, a second source, and a second destination are illegal.
- B.DATR is mandatory and permits only DataType, RMode, and Sat. DataType is exactly S8 or U8.
- The source valid region and physical Col match LB1, LB0, and LB2 respectively. Source and destination are row-major and their capacities independently match their DataTypes.
- A present B.IOR consumes RegSrc0 as a positive, finite, nonzero raw FP32 multiplier and RegSrc1 as a canonically encoded zero point in the destination integer type. RegSrc2 and RegDst are zero.
- The complete FP32 source valid region is defined and contains valid encodings. All participating masks are equal; PE_MASK zero is a strict no-op.

## State effects

- For every valid element x, compute x multiplied by MultiplierFP32 plus ZeroPoint, then round using RMode.
- Sat one clamps the rounded value to S8 or U8 range. Sat zero converts modulo the destination width.
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

- BSTART.SFU TQUANT, FP32; B.DATR S8, RNE, Sat=1; B.DIM LB0=16; B.IOT T1, mask=1111, <last>, ->T0<1>; BSTOP
