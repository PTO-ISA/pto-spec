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

`TCVT` 把一个 Local 源 Tile 的每个有效元素转换为另一种元素类型，并把结果写入一个新分配的 Local 目标 Tile。与 `TADD` 不同，它的目标类型独立于源类型选择，并接受逐指令的 `RMode` 与 `Sat` 控制。

设计要点：`TCVT` 由 `BSTART.VEC` Mode 0 Function 27（TEPL 选择器 `0x01B`）选中，没有独立 opcode。`BSTART` 头部给出源类型 `SrcDataType`；目标类型 `DstDataType` 来自 `B.DATR`。

<!-- PTO-READER-BLOCK: tile-tcvt-mechanism role=mechanism -->
## 元素与 Tile 机制

首先解析目标类型。具体的 `B.DATR` `DataType` 选择 `DstDataType`。省略 `B.DATR`，或把 `DataType` 编码为 `DTYPE_NONE`（代码 31），会使目标继承 `SrcDataType`。编码为零的 `DataType` 选择 `FP64`，并不表示缺省。

设计要点：代码 0 已经表示 `FP64`，因此继承需要一个单独的哨兵值。这使“未请求目标类型”与显式请求 `FP64` 保持区分。

接着解析舍入方式。`RMode` 代码 0 是操作默认值：当 `SrcDataType` 为浮点类型且 `DstDataType` 为整数类型时使用向零舍入（RTZ），其他所有需要舍入的转换使用就近舍入到偶数（RNE）。代码 1 至 7 分别显式选择 RNE、RTZ、RTM、RTP、RNA、RTO 与 RHB，并总是覆盖默认值。

设计要点：RTZ 默认值使默认的浮点到整数转换直接舍弃小数部分，而浮点到浮点的变窄转换保留 RNE 默认值。

`Sat` 控制范围溢出。`Sat=0` 时，溢出的浮点结果在目标格式有无穷时变为无穷，溢出的整数结果只保留舍入值的低位。`Sat=1` 时，结果被钳位到目标类型的最大或最小有限值。

完整预检之后，源被快照，每个有效逻辑元素独立转换。公共 Tile 规则覆盖 `FP64`、`FP32`、`TF32`、`HF32`、`FP16`、`BF16`、`E4M3`、`E5M2`，以及有符号或无符号 64、32、16、8 位整数。reduced 浮点目标使用各自精确 fixed encoder。`E8M0`、`E6M2`、`RCPE6M2`、`E2M1X2` 与 `E1M2X2` 保持专用类型对规则。更广的 Tile 集合不会新增标量转换 opcode 或类型对。

<!-- PTO-READER-BLOCK: tile-tcvt-inputs role=inputs-outputs -->
## 操作数角色与描述符

- `source0` 是持久的 Local 源，其位按 `SrcDataType` 解释。
- `destination0` 是新分配的 Local Tile，其后备类型为解析得到的 `DstDataType`。
- `numeric_control` 不是 Tile，而是由 `RMode` 与 `Sat` 解析得到的舍入方式与饱和设置。

一条终止 `B.IOT` 绑定源与目标。`B.IOR`、`B.IOS`、第二个源以及第二条绑定均非法。`PE_MASK=0000` 是严格无操作，发生在模式、描述符、分配或载荷检查之前。

只有当两种类型都非打包、元素位宽相同且载体兼容时，源的后备类型才可以不同于 `SrcDataType`。源描述符永远不会被重新标记类型。

对普通源，目标的 `Row`、`Col`、`ValidRow` 与 `ValidCol` 与源相同。显式 `Layout` 代码同时给出源必须具有的布局以及目标得到的布局；`NORM` 使两侧都保持 `RowMajor`。

对 `CUBE_M16` 或 `CUBE_M32` 源，`B.DATR` `Layout` 必须保持 `NORM`，且必须省略 `LB2`。目标保持相同的 CUBE 布局以及相同的 `ValidRow` 与 `ValidCol`，而其物理形状、CELL 数量与最小 `TSize` 由 `DstDataType` 推导。

设计要点：CUBE 物理几何取决于元素位宽。为目标独立推导几何，使得例如 `FP32` 的 CUBE Tile 可以转换为更窄的类型，而无需先做布局转换。

对于 `CUBE_M32`，`FP64`、`S64` 或 `U64` 源或目标使用 double-CELL 映射，同时保持逻辑形状。若源或目标为 64 位，`CUBE_M16` 会拒绝该类型对。

<!-- PTO-READER-BLOCK: tile-tcvt-effects role=effects -->
## 发布、已定义性与填充

转换后的载荷、累积的数值状态、填充、每个元素的已定义性以及目标描述符作为一次操作发布。被拒绝的指令束没有任何目标效果，源也保持不变。

数值状态使用五个标志 NV、DZ、OF、UF 与 NX。每个被转换元素的标志按位或累积，并在发布时记录。

`ValidRow x ValidCol` 之外的物理元素接收所选 `PadValue`。`Zero` 写入零；`Max` 与 `Min` 写入 `DstDataType` 的最大与最小有限值；`Null` 使这些元素保持未定义。省略 `B.DATR` 选择 `Null`，而显式编码 `00` 选择 `Zero`。

源可以与目标别名，执行时观察到完整的执行前源值。`TCVT` 没有全局内存效果。存在 ExecutionMask 时，非活动坐标接收该掩码规定的零值或合并值，且不贡献状态。

<!-- PTO-READER-BLOCK: tile-tcvt-constraints role=constraints -->
## 类型、布局与故障边界

除 `HiF4X2` 外，每个已分配的 `DataType` 都可以作为 `TCVT` 类型，但受以下类型对限制约束：

- `E2M1X2` 与 `E1M2X2` 只能与 `FP32`、`FP16` 或 `BF16` 互相转换，且恰好一侧必须是打包类型。
- `E6M2` 只能与 `FP16` 或 `BF16` 互相转换，且只能使用 RNE 或 RNA 舍入。
- `RCPE6M2` 只能作为源，只能转换为 `FP16` 或 `BF16`，且只能使用 RNE 或 RNA 舍入。
- `E8M0` 只能与 `FP16`、`BF16` 或 `FP32` 互相转换。

对 `E8M0` 目标，零、负值与 NaN 产生 `0xFF` 并记录 NV。正的有限值在按 `RMode` 舍入其二进制指数后产生代码 `exponent+127`。正无穷以及高于范围的值在 `Sat=0` 时产生 `0xFF`，在 `Sat=1` 时产生 `0xFE`；低于范围的值产生 `0xFF` 或 `0x00`。`E8M0` 源代码 `0xFF` 产生目标的规范静默 NaN，且不记录 NV。

`Canonicalize=1` 为保留值，会在任何效果之前被拒绝。维度缺失或为零，类型、形状、容量、布局、编码或已定义性不匹配，或类型对与舍入方式不受支持时，会在目标分配之前引发 `Fault_TileLegality`。对逻辑形状已被接受的 CUBE 源，目标 `TSize` 不足时引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: tile-tcvt-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

把 `FP32` 转换为 `S32` 并使用默认 `RMode` 时，源行 `[2.7, -2.7, 3.0e9]` 使用 RTZ。在 `Sat=1` 下目标行为 `[2, -2, 2147483647]`，记录的状态包含 OF 与 NX。

把 `FP32` 转换为 `FP16` 并使用默认 RNE 时，值 `65536.0` 超过 `FP16` 的最大有限值 65504。`Sat=0` 时它变为 `+inf`；`Sat=1` 时它变为 `65504`。两者都记录 OF 与 NX。

对 8 x 64 的 `RowMajor` Tile，头部写作 `BSTART.VEC TCVT, FP32`，`B.DATR` 选择目标 `DataType` `FP16`。源占 8 x 64 x 4 = 2048 字节，目标需要 8 x 64 x 2 = 1024 字节。
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
    // Assigned identity is separate from TCVT pair legality. HiF4X2 remains
    // an assigned Matrix/MX payload but is not a standalone TCVT type.
    return data_type != TileDataType_HiF4X2;
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
- TCVT legal pairs are profile-scoped: FP32/FP16/BF16 <-> E2M1X2/E1M2X2; FP16/BF16 <-> E6M2; RCPE6M2 -> FP16/BF16. No pair contains HiF4X2, and RCPE6M2 has no destination encoding. Reserved five-bit DataType codes reject before effects.
- Every assigned Layout code has executable indexing. The source descriptor matches the transform source layout and the destination descriptor matches its target layout; CUBE_M16 and CUBE_M32 conversions retain the source layout.
- Canonicalize=1 is reserved-illegal before effects. CUBE_M16 and CUBE_M32 sources with Canonicalize=0 preserve the source layout while the destination independently derives its geometry from the destination DataType. An ordinary source requires Canonicalize=0.
- The source valid region is fully defined and contains valid encodings. PE_MASK=0000 is a strict no-op before schema, descriptor, allocation, or payload checks.
- Under the named hardware profile, an E8M0 destination accepts exactly FP16, BF16, or FP32 sources. E8M0 as a source accepts exactly FP16, BF16, or FP32 destinations; 0x00..0xFE denote powers of two and 0xFF produces the target canonical quiet NaN without NV. Every other E8M0 pair rejects before destination allocation.
- The BSTART DataType is the TCVT source operation interpretation, not necessarily the source backing DataType. RowMajor and CUBE_M16/M32 sources may differ only when backing and operation types are non-packed, equal-width, and carrier-compatible; the operation view never mutates the backing descriptor. The destination backing type is the resolved B.DATR destination type.
- A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.

## State effects

- Snapshot the persistent source, convert every valid logical element under the resolved rounding and saturation controls, and write the corresponding logical coordinate in the destination layout.
- Define or undefine every physical padding coordinate according to PadValue and publish the destination; ordinary conversions use the resolved public layout, while CUBE_M16 and CUBE_M32 conversions retain the source CUBE layout.
- The source may alias the destination; execution observes the complete pre-execution source snapshot.
- For a supported conversion to an E8M0 destination, map the rounded base-two exponent to code exponent+127 and accumulate exact NV/UF/OF/NX status before atomic publication.
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
- For conversion to an E8M0 destination, zero, negative values, and NaNs produce 0xFF with NV. Positive infinity follows the overflow rule. Finite values below 2^-127 or above 2^127 produce 0xFF when Sat=0 or clamp to 0x00/0xFE when Sat=1, with UF/OF plus NX.

## Examples

- BSTART.VEC TCVT, SrcDataType; B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP
