<!-- GENERATED FROM: asl/arch/profile/e8m0-conversion.asl -->
# E8m0 Conversion

**Normative ASL source:** `asl/arch/profile/e8m0-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-E8M0-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-e8m0-purpose role=purpose-scope -->
## 用途与范围

本单元为目标类型为 `E8M0` 的 `TCVT` 提供 PTO 参考转换路径。它定义可接受源类型、`RMode` 下的指数选择、异常编码、饱和端点以及五位数值状态。

<!-- PTO-READER-BLOCK: arch-e8m0-concepts role=concepts-state -->
## 输入与表示

- 支持的源类型为 `FP16`、`BF16` 与 `FP32`；其他源到 `E8M0` 的组合不能通过类型组合判定函数。
- 正有限输入被分解为有效数与二进制指数。
- 有限结果采用指数加 `127` 的编码，产生 `0x00` 到 `0xfe`；异常路径使用 `0xff`。

<!-- PTO-READER-BLOCK: arch-e8m0-rules role=rules-interactions -->
## 转换规则

- 精确的二次幂保留其指数，并且不报告不精确状态。
- 非二次幂使用 `ReferenceE8M0RoundExponent`，该函数实现 `RTM`、`RTP`、`RTZ`、`RTO`、`RNE`、`RNA` 与 `RHB` 选择。
- 零、负值与 NaN 返回 `0xff` 并报告 `NV`。
- `ReferenceFloatToE8M0` 还会把 `NumericValue_InvalidEncoding` 路由到 `0xff` 并报告 `NV`。
- 正无穷以及有限上溢或下溢在不饱和时选择 `0xff`，在饱和时选择有限端点，并报告相应的 `OF` 或 `UF` 加 `NX`。

<!-- PTO-READER-BLOCK: arch-e8m0-boundaries role=boundaries -->
## 边界

`TileProfileConvert` 只把目标 `E8M0` 委托给此路径。非浮点整数目标使用 `NormalizeTileInteger`；其他浮点目标由本所有者原样返回。`Canonicalize` 仍是此转换辅助函数之外的表示问题。

<!-- PTO-READER-BLOCK: arch-e8m0-example role=example-usage -->
## 非规范转换示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-e8m0-related role=related-owners-navigation -->
## 相关所有者

- 参考量化单元提供共享的有限值与数值辅助函数。
- 数值格式所有者对源编码分类；`TCVT` 拥有操作合法性与发布行为。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/e8m0-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-E8M0-CONVERSION","surface":"arch","classification":["profile","e8m0-conversion"],"depends_on":["PTO-ARCH-PROFILE-REFERENCE-CONVERSION","PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS"]}

// NDF-BEGIN: PTO-TCVT-E8M0-PROFILE-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// TCVT to E8M0 MUST accept only FP16, BF16, and FP32 sources. Positive
// finite values MUST round their base-two exponent under the selected RMode.
// Zero, negative values, and NaNs MUST produce 0xFF with NV. Positive
// infinity and finite range overflow or underflow MUST produce 0xFF when Sat
// is zero and the corresponding finite endpoint when Sat is one, with exact
// OF or UF plus NX status. Canonicalize MUST retain its representation role.
// NDF-END: PTO-TCVT-E8M0-PROFILE-001

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
    if destination_type == TileDataType_E8M0 then
        return HardwareTCVTE8M0SourceTypeSupported(source_type);
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

implementation func TileProfileConvert(
    value: Word,
    source_type: TileDataType,
    destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if ReferenceCommonConversionTypeSupported(source_type) &&
       ReferenceCommonConversionTypeSupported(destination_type) then
        return ReferenceCommonConvert(
            value, source_type, destination_type, control);
    elsif destination_type == TileDataType_E8M0 then
        return ReferenceFloatToE8M0(value, source_type, control);
    elsif !TileDataTypeIsFloating(destination_type) then
        return (
            NormalizeTileInteger(value, destination_type),
            Zeros{5});
    end;
    return (value, Zeros{5});
end;
// DOC-END: operation
```
<!-- GENERATED-ASL-END: unit -->
