<!-- GENERATED FROM: asl/tile/model/numeric/e8m0-conversion.asl -->
# E8m0 Conversion

**Normative ASL source:** `asl/tile/model/numeric/e8m0-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-NUMERIC-E8M0-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-purpose role=purpose-scope -->
## 作用与范围

本单元拥有两部分内容。

- TCVT 类型对与舍入模式的合法性谓词 `HardwareTCVTTypePairSupported` 与 `HardwareTCVTRoundingModeSupported`。
- 从 FP16、BF16 或 FP32 到 E8M0 的转换 `ReferenceFloatToE8M0`，及其指数舍入辅助函数 `ReferenceE8M0RoundExponent`。

E8M0 是一种八位缩放格式，只存储带偏置的指数。从 `0x00` 到 `0xFE` 的编码 `c` 表示 2^(c - 127)，`0xFF` 是 NaN。反向转换（E8M0 到浮点）位于 TCVT conversion 单元。

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-concepts role=concepts-state -->
## 概念与可见状态

转换结果是一个值字加一个五位标志集合。ASL 使用的标志常量为：`0x01` NV（无效）、`0x02` DZ、`0x04` OF（上溢）、`0x08` UF（下溢）与 `0x10` NX（不精确）。TCVT 把所有已转换元素的标志按位或到粘滞数值状态中。

`HardwareTCVTTypePairSupported` 返回：

- 任何包含 HiF4X2 的类型对，以及以 RCPE6M2 为目标的类型对，返回 FALSE。
- RCPE6M2 为源：仅当目标为 FP16 或 BF16 时为 TRUE。
- E8M0 为源：仅当目标为 FP16、BF16 或 FP32 时为 TRUE。
- 任一侧为 E6M2：仅 E6M2 到 FP16 或 BF16，以及 FP16 或 BF16 到 E6M2 为 TRUE。
- 任一侧为 E2M1X2 或 E1M2X2：仅当一侧为打包类型、另一侧为 FP32、FP16 或 BF16 时为 TRUE。
- E8M0 为目标：仅当源为 FP16、BF16 或 FP32 时为 TRUE。
- 其他所有类型对：TRUE。

涉及 E6M2 或 RCPE6M2 时，`HardwareTCVTRoundingModeSupported` 只允许 RNE 与 RNA，其他情况允许所有模式。

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-rules role=rules-interactions -->
## 规则与交互

`ReferenceFloatToE8M0` 断言源为 FP16、BF16 或 FP32，然后对其分类。

- 零、负值、负无穷、NaN 与无效编码得到 `0xFF`，并带 NV。
- 正无穷得到 `0xFF` 并带 OF 与 NX（`0x14`）；设置 `Sat` 时得到 `0xFE`。

正有限值被分解为有效数乘以 2^exponent。其下取整指数为 `exponent + highest set bit`，即 floor(log2 value)。

- 下取整指数小于 -127：得到 `0xFF`，设置 `Sat` 时得到 `0x00`，并带 UF 与 NX（`0x18`）。
- 下取整指数为 127 且不是 2 的精确幂：得到 `0xFF`，设置 `Sat` 时得到 `0xFE`，并带 OF 与 NX。
- 否则，舍入后的指数 `r` 给出编码 `r + 127`；如果值不是 2 的精确幂，则带 NX。

设计要点：舍入作用于指数，而不是值。RTM 取下取整，RTP 取上取整。RTZ 使指数趋向零，因此小于 1 的值在数值上向上舍入。RTO 选择奇数指数。就近模式把值与几何中点 2^(floor + 0.5) 比较，方法是比较有效数的平方与 2^(2 x highest + 1)。整数的平方永远不是 2 的奇数次幂，因此对这些输入不会到达平局分支。

设计要点：越界检查在舍入之前进行。(2^127, 2^128) 内的值即使在 RTZ 或 RTM 下也是上溢，小于 2^-127 的值即使在 RTP 下也是下溢。

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-boundaries role=boundaries -->
## 架构边界

两个合法性谓词由 TCVT 操作数合法性与块 TCVT schema 检查调用，因此不支持的类型对或模式会在目标分配之前被拒绝。

`ReferenceFloatToE8M0` 由 formats 单元中的 `TileProfileConvert` 到达。它本身不记录标志；标志由 TCVT 发布。

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-example role=example-usage -->
## 非规范阅读示例

把 FP32 3.0（`0x40400000`）转换为 E8M0。

- 有效数 `0xC00000`，指数 128 - 150 = -22，最高置位为 23，因此下取整指数为 1。
- RNE：平方为 `0x900000000000`，边界为 2^47 = `0x800000000000`。平方更大，因此指数舍入为 2。编码为 2 + 127 = 129 = `0x81`（值 4.0），并带 NX `0x10`。
- RTZ 或 RTM：指数保持为 1，得到编码 `0x80`（值 2.0），并带 NX。

对 FP32 2.5，平方小于边界，因此 RNE 得到 `0x80`。

<!-- PTO-READER-BLOCK: tile-model-numeric-e8m0-conversion-related role=related-owners-navigation -->
## 相关归属

- [TCVT conversion](tcvt-conversion.md) 拥有 E8M0 到浮点的转换。
- [Formats](formats.md) 拥有 `TCVT` 以及到本单元的分派。
- [E8M0 format](../../../arch/data-types/formats/e8m0.md) 拥有该编码。
- [Numeric status](../../../arch/state/numeric-status.md) 拥有粘滞标志。
- [TCVT](../../elementwise-tile-tile/format-conversion/TCVT.md) 是指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/numeric/e8m0-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-NUMERIC-E8M0-CONVERSION","surface":"tile","classification":["model","numeric","e8m0-conversion"],"depends_on":["PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION","PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION","PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS"]}

// NDF-BEGIN: PTO-TCVT-E8M0-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// TCVT to E8M0 MUST accept only FP16, BF16, and FP32 sources. Positive
// finite values MUST round their base-two exponent under the selected RMode.
// Zero, negative values, and NaNs MUST produce 0xFF with NV. Positive
// infinity and finite range overflow or underflow MUST produce 0xFF when Sat
// is zero and the corresponding finite endpoint when Sat is one, with exact
// OF or UF plus NX status. Canonicalize MUST retain its representation role.
// TCVT from E8M0 MUST accept only FP16, BF16, and FP32 destinations. Codes
// 0x00 through 0xFE denote 2^(code-127) and use the ordinary target rounding,
// saturation, overflow, underflow, and inexact rules. Code 0xFF MUST produce
// the target canonical quiet NaN without NV.
// NDF-END: PTO-TCVT-E8M0-001

// DOC-BEGIN: operation
pure func HardwareTCVTE8M0SourceTypeSupported(
    source_type: TileDataType) => boolean
begin
    return source_type == TileDataType_FP16 ||
           source_type == TileDataType_BF16 ||
           source_type == TileDataType_FP32;
end;

pure func HardwareTCVTTypePairSupported(
    source_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    // HiF4X2 is the payload of the composite Matrix/MX format, not a
    // standalone TCVT scalar. The two newly allocated scale identities have
    // deliberately narrow conversion profiles; width equality does not widen
    // these profiles.
    if source_type == TileDataType_HiF4X2 ||
       destination_type == TileDataType_HiF4X2 then
        return FALSE;
    end;
    if destination_type == TileDataType_RCPE6M2 then
        return FALSE;
    end;
    if source_type == TileDataType_RCPE6M2 then
        return destination_type == TileDataType_FP16 ||
               destination_type == TileDataType_BF16;
    end;
    if source_type == TileDataType_E8M0 then
        return destination_type == TileDataType_FP16 ||
               destination_type == TileDataType_BF16 ||
               destination_type == TileDataType_FP32;
    end;
    if source_type == TileDataType_E6M2 ||
       destination_type == TileDataType_E6M2 then
        return (source_type == TileDataType_E6M2 &&
                (destination_type == TileDataType_FP16 ||
                 destination_type == TileDataType_BF16)) ||
               (destination_type == TileDataType_E6M2 &&
                (source_type == TileDataType_FP16 ||
                 source_type == TileDataType_BF16));
    end;
    if source_type == TileDataType_E2M1X2 ||
       source_type == TileDataType_E1M2X2 ||
       destination_type == TileDataType_E2M1X2 ||
       destination_type == TileDataType_E1M2X2 then
        let source_ok = source_type == TileDataType_E2M1X2 ||
            source_type == TileDataType_E1M2X2 ||
            source_type == TileDataType_FP32 ||
            source_type == TileDataType_FP16 ||
            source_type == TileDataType_BF16;
        let destination_ok = destination_type == TileDataType_E2M1X2 ||
            destination_type == TileDataType_E1M2X2 ||
            destination_type == TileDataType_FP32 ||
            destination_type == TileDataType_FP16 ||
            destination_type == TileDataType_BF16;
        let source_packed = source_type == TileDataType_E2M1X2 ||
            source_type == TileDataType_E1M2X2;
        let destination_packed = destination_type == TileDataType_E2M1X2 ||
            destination_type == TileDataType_E1M2X2;
        return source_ok && destination_ok &&
               source_packed != destination_packed;
    end;
    if destination_type == TileDataType_E8M0 then
        return HardwareTCVTE8M0SourceTypeSupported(source_type);
    end;
    return TRUE;
end;

pure func HardwareTCVTRoundingModeSupported(
    source_type: TileDataType,
    destination_type: TileDataType,
    mode: NumericRoundingMode) => boolean
begin
    if source_type == TileDataType_E6M2 ||
       destination_type == TileDataType_E6M2 ||
       source_type == TileDataType_RCPE6M2 then
        return mode == NumericRound_RNE || mode == NumericRound_RNA;
    end;
    return TRUE;
end;

pure func ReferenceE8M0HighestSetBit(
    significand: Word) => integer {0..63}
begin
    assert !IsZero(significand);
    var highest: integer {0..63} = 0;
    for position = 0 to 63 do
        if significand[position] == '1' then
            highest = position as integer {0..63};
        end;
    end;
    return highest;
end;

pure func ReferenceE8M0RoundExponent(
    significand: Word,
    exponent: integer {-1074..1023},
    mode: NumericRoundingMode) => (integer {-149..128}, boolean)
begin
    let highest = ReferenceE8M0HighestSetBit(significand);
    let floor_candidate = exponent + highest;
    assert -149 <= floor_candidate && floor_candidate <= 127;
    let floor_exponent = floor_candidate as integer {-149..127};
    let exact_power = significand ==
        LSL(Zeros{PTO_XLEN} + 1, highest);
    if exact_power then
        return (floor_exponent, TRUE);
    end;

    let ceiling_exponent = (floor_exponent + 1) as integer {-148..128};
    if mode == NumericRound_RTM then
        return (floor_exponent, FALSE);
    elsif mode == NumericRound_RTP then
        return (ceiling_exponent, FALSE);
    elsif mode == NumericRound_RTZ then
        if floor_exponent < 0 then
            return (ceiling_exponent, FALSE);
        else return (floor_exponent, FALSE);
        end;
    elsif mode == NumericRound_RTO then
        if floor_exponent MOD 2 != 0 then
            return (floor_exponent, FALSE);
        else return (ceiling_exponent, FALSE);
        end;
    end;

    let square = MultiplyWord(significand, significand);
    let boundary_shift = 2 * highest + 1;
    assert boundary_shift <= 127;
    let boundary = LSL(
        Zeros{PTO_XLEN} + 1,
        boundary_shift as integer {0..127});
    if UInt(square) < UInt(boundary) then
        return (floor_exponent, FALSE);
    elsif UInt(square) > UInt(boundary) then
        return (ceiling_exponent, FALSE);
    elsif mode == NumericRound_RNE then
        if floor_exponent MOD 2 == 0 then
            return (floor_exponent, FALSE);
        else return (ceiling_exponent, FALSE);
        end;
    elsif mode == NumericRound_RNA then
        if floor_exponent < 0 then
            return (floor_exponent, FALSE);
        else return (ceiling_exponent, FALSE);
        end;
    else
        assert mode == NumericRound_RHB;
        return (ceiling_exponent, FALSE);
    end;
end;

func ReferenceFloatToE8M0(
    value: Word,
    source_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert HardwareTCVTE8M0SourceTypeSupported(source_type);
    let value_class = TileNumericValueClass(source_type, value);
    if value_class == NumericValue_InvalidEncoding ||
       NumericValueClassIsNaN(value_class) ||
       NumericValueClassIsZero(value_class) ||
       value_class == NumericValue_NegativeInfinity ||
       value_class == NumericValue_NegativeNormal ||
       value_class == NumericValue_NegativeSubnormal then
        return (Zeros{PTO_XLEN} + 0xff, Zeros{5} + 0x01);
    elsif value_class == NumericValue_PositiveInfinity then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;

    let (available, negative, significand, exponent) =
        TileNumericFiniteDecomposition(source_type, value);
    assert available && !negative && !IsZero(significand);
    let highest = ReferenceE8M0HighestSetBit(significand);
    let floor_candidate = exponent + highest;
    assert -149 <= floor_candidate && floor_candidate <= 127;
    let floor_exponent = floor_candidate as integer {-149..127};
    let exact_power = significand ==
        LSL(Zeros{PTO_XLEN} + 1, highest);
    if floor_exponent < -127 then
        return (
            if control.saturating then Zeros{PTO_XLEN}
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x18);
    elsif floor_exponent == 127 && !exact_power then
        return (
            if control.saturating then Zeros{PTO_XLEN} + 0xfe
            else Zeros{PTO_XLEN} + 0xff,
            Zeros{5} + 0x14);
    end;

    let (rounded_exponent, exact) = ReferenceE8M0RoundExponent(
        significand, exponent, control.rounding_mode);
    assert -127 <= rounded_exponent && rounded_exponent <= 127;
    let code = (rounded_exponent + 127) as integer {0..254};
    return (
        Zeros{PTO_XLEN} + code,
        if exact then Zeros{5} else Zeros{5} + 0x10);
end;

// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
