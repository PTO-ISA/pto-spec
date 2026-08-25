<!-- GENERATED FROM: asl/arch/profile/matrix-quantization.asl -->
# Matrix Quantization

**Normative ASL source:** `asl/arch/profile/matrix-quantization.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-MATRIX-QUANTIZATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-matrix-quant-purpose role=purpose-scope -->
## 用途与范围

本单元提供矩阵 `PreQuant` 和目标转换所使用的逐位精确数值辅助函数。它覆盖 FP19 参数、有符号整数舍入与饱和、binary16 与 FP8 编码以及浮点目标选择。

<!-- PTO-READER-BLOCK: arch-matrix-quant-concepts role=concepts-state -->
## 数值构件

- `MatrixQuantParameter`、`MatrixShiftParameter` 与 `MatrixQuantOffset` 解码缩放和偏移控制。
- `MatrixRoundMagnitude`、`MatrixRoundAndSaturateSigned` 与 `MatrixShiftS32ToS16` 实现整数舍入、缩窄和状态生成。
- `ReferenceBinary16Encoding`、`ReferenceFP8Encoding` 与 `ReferenceMatrixFloatingEncoding` 生成目标编码和标志。

<!-- PTO-READER-BLOCK: arch-matrix-quant-rules role=rules-interactions -->
## 量化路径

矩阵 `PreQuant` 先乘以所选 FP19 缩放值，在指定的 `S5`、`S9` 或 `S17` 中间值上舍入并始终执行饱和，再加上有符号偏移，最后才执行目标编码。移位模式执行指定的一到十六位 ASR，并对 `S16` 结果执行饱和。

最终整数目标编码是独立阶段：只有选择 `control.saturating` 时，`ReferenceMatrixIntegerEncoding` 才会将越界的最终值钳制到目标范围。浮点编码器另行区分精确、不精确、上溢、下溢和特殊结果，并返回编码后的 `Word` 与五位状态。

<!-- PTO-READER-BLOCK: arch-matrix-quant-boundaries role=boundaries -->
## 格式边界

binary16 逻辑区分 `FP16` 与 `BF16`。FP8 候选选择按请求的舍入规则比较相邻有限编码。`ReferenceMatrixFloatingEncoding` 把 `FP32`、binary16 与 FP8 目标路由到相应的格式实现；不支持的类型组合由调用方处理。

<!-- PTO-READER-BLOCK: arch-matrix-quant-example role=example-usage -->
## 非规范舍入示例

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-matrix-quant-related role=related-owners-navigation -->
## 相关所有者

- 参考量化单元提供共享的实数值与 FP32 辅助函数。
- FP19 定义缩放表示；矩阵后处理在完整结果流水线中安排这些辅助函数。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/matrix-quantization.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-MATRIX-QUANTIZATION","surface":"arch","classification":["profile","matrix-quantization"],"depends_on":["PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION","PTO-ARCH-DATA-TYPES-FP19"]}
// Bit-exact numeric helpers for B.FPATR matrix post-processing.
// NDF-BEGIN: PTO-MATRIX-QUANT-BITEXACT-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Matrix PreQuant MUST multiply by the selected FP19 scale, round and
// saturate at an assigned S5, S9, or S17 intermediate, add the signed offset,
// and only then apply final destination encoding. Shift modes MUST perform
// their assigned one-through-sixteen-bit ASR and saturate its S16 result.
// NDF-END: PTO-MATRIX-QUANT-BITEXACT-001

pure func MatrixQuantParameter(fp19: bits(19), offset: Word,
                               offset_width: integer {0,5,9,17}) => Word
begin
    var result = Zeros{PTO_XLEN};
    result[31:13] = fp19;
    case offset_width of
        when 0 => return result;
        when 5 => result[41:37] = offset[4:0];
        when 9 => result[45:37] = offset[8:0];
        when 17 => result[53:37] = offset[16:0];
    end;
    return result;
end;

pure func MatrixShiftParameter(code: integer {0..15}) => Word
begin
    var result = Zeros{PTO_XLEN};
    result[35:32] = Zeros{4} + code;
    return result;
end;

pure func MatrixQuantOffset(parameter: Word,
                            width: integer {0,5,9,17}) => integer
begin
    case width of
        when 0 => return 0;
        when 5 => return SInt(parameter[41:37]);
        when 9 => return SInt(parameter[45:37]);
        when 17 => return SInt(parameter[53:37]);
    end;
end;

pure func MatrixMagnitudeRoundingMode(
    mode: NumericRoundingMode, negative: boolean) => NumericRoundingMode
begin
    if !negative then return mode; end;
    if mode == NumericRound_RTP then return NumericRound_RTM;
    elsif mode == NumericRound_RTM then return NumericRound_RTP;
    end;
    return mode;
end;

func MatrixRoundMagnitude(
    value: real, mode: NumericRoundingMode,
    negative: boolean) => integer
begin
    if negative && mode == NumericRound_RHB then
        let lower = RoundDown(value);
        let fraction = value - Real(lower);
        if fraction <= 0.5 then return lower;
        else return lower + 1;
        end;
    end;
    return FloatingToInteger(
        value, MatrixMagnitudeRoundingMode(mode, negative));
end;

func MatrixRoundAndSaturateSigned(
    value: real, width: integer {5,9,17},
    rounding_mode: NumericRoundingMode)
    => (integer {-65536..65535}, bits(5))
begin
    let rounded = FloatingToInteger(value, rounding_mode);
    let minimum = if width == 5 then -16
        else if width == 9 then -256
        else -65536;
    let maximum = if width == 5 then 15
        else if width == 9 then 255
        else 65535;
    let overflow = rounded < minimum || rounded > maximum;
    var selected = rounded;
    if selected < minimum then selected = minimum;
    elsif selected > maximum then selected = maximum;
    end;
    let flags = if overflow then Zeros{5} + 0x14
        else if Real(rounded) != value then Zeros{5} + 0x10
        else Zeros{5};
    return (
        selected as integer {-65536..65535},
        flags);
end;

func MatrixShiftS32ToS16(
    value: bits(32), shift: integer {1..16}) => (Word, bits(5))
begin
    let shifted = SInt(ASR(value, shift));
    if shifted < -32768 then
        return (Zeros{PTO_XLEN} + 0xffffffffffff8000,
                Zeros{5} + 0x14);
    elsif shifted > 32767 then
        return (Zeros{PTO_XLEN} + 0x7fff, Zeros{5} + 0x14);
    end;
    return (
        SignExtend{PTO_XLEN}(Zeros{16} + shifted),
        Zeros{5});
end;

func ReferenceMatrixIntegerEncoding(
    value: real, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    let rounded = FloatingToInteger(value, control.rounding_mode);
    let minimum = ReferenceIntegerValue(
        TileIntegerMinimum(destination_type), destination_type);
    let maximum = ReferenceIntegerValue(
        TileIntegerMaximum(destination_type), destination_type);
    let overflow = rounded < minimum || rounded > maximum;
    var selected = rounded;
    if control.saturating && overflow then
        if selected < minimum then selected = minimum;
        else selected = maximum;
        end;
    end;
    let flags = if overflow then Zeros{5} + 0x14
        else if Real(rounded) != value then Zeros{5} + 0x10
        else Zeros{5};
    return (
        NormalizeTileInteger(Zeros{PTO_XLEN} + selected,
            destination_type),
        flags);
end;

func MatrixQuantizedAffine(
    value: real, scale: real, offset: integer,
    intermediate_width: integer {0,5,9,17},
    output_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if intermediate_width == 0 then
        return ReferenceMatrixIntegerEncoding(
            value * scale + Real(offset), output_type, control);
    end;
    let width = intermediate_width as integer {5,9,17};
    let (intermediate, intermediate_flags) =
        MatrixRoundAndSaturateSigned(
            value * scale, width, control.rounding_mode);
    let (encoded, final_flags) = ReferenceMatrixIntegerEncoding(
        Real(intermediate + offset), output_type, control);
    return (encoded, intermediate_flags OR final_flags);
end;

func ReferenceBinary16Encoding(
    value: real, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_FP16 ||
           destination_type == TileDataType_BF16;
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    var normalized = if negative then -value else value;
    var exponent: integer {-149..128} = 0;
    for step = 1 to 128 looplimit 128 do
        if normalized >= 2.0 && exponent < 128 then
            normalized = normalized / 2.0;
            exponent = (exponent + 1) as integer {-149..128};
        end;
    end;
    for step = 1 to 149 looplimit 149 do
        if normalized < 1.0 && exponent > -149 then
            normalized = normalized * 2.0;
            exponent = (exponent - 1) as integer {-149..128};
        end;
    end;

    let bf16 = destination_type == TileDataType_BF16;
    let fraction_bits = if bf16 then 7 else 10;
    let fraction_scale = if bf16 then 128 else 1024;
    let bias = if bf16 then 127 else 15;
    let maximum_exponent = if bf16 then 127 else 15;
    let minimum_exponent = if bf16 then -126 else -14;
    let minimum_subnormal_exponent = if bf16 then -133 else -24;
    let sign = if negative then 0x8000 else 0;

    if exponent > maximum_exponent then
        let overflow = if control.saturating then
            (if bf16 then 0x7f7f else 0x7bff)
        else
            (if bf16 then 0x7f80 else 0x7c00);
        return (Zeros{PTO_XLEN} + sign + overflow,
                Zeros{5} + 0x14);
    end;

    if exponent < minimum_exponent then
        let scaled = (if negative then -value else value) /
            ReferencePowerOfTwo(
                minimum_subnormal_exponent as integer {-149..127});
        var rounded = MatrixRoundMagnitude(
            scaled, control.rounding_mode, negative);
        if rounded >= fraction_scale then
            return (Zeros{PTO_XLEN} + sign + fraction_scale,
                    if Real(rounded) == scaled then Zeros{5}
                    else Zeros{5} + 0x18);
        end;
        if rounded < 0 then rounded = 0; end;
        return (Zeros{PTO_XLEN} + sign + rounded,
                if Real(rounded) == scaled then Zeros{5}
                else Zeros{5} + 0x18);
    end;

    let scaled = normalized * Real(fraction_scale);
    var rounded = MatrixRoundMagnitude(
        scaled, control.rounding_mode, negative);
    var encoded_exponent = exponent + bias;
    if rounded == 2 * fraction_scale then
        rounded = fraction_scale;
        assert encoded_exponent <= 254;
        encoded_exponent =
            (encoded_exponent + 1) as integer {-134..255};
    end;
    if encoded_exponent >= 2 * bias + 1 then
        let overflow = if control.saturating then
            (if bf16 then 0x7f7f else 0x7bff)
        else
            (if bf16 then 0x7f80 else 0x7c00);
        return (Zeros{PTO_XLEN} + sign + overflow,
                Zeros{5} + 0x14);
    end;
    let fraction = rounded - fraction_scale;
    let encoded = encoded_exponent * fraction_scale + fraction;
    return (Zeros{PTO_XLEN} + sign + encoded,
            if Real(rounded) == scaled then Zeros{5}
            else Zeros{5} + 0x10);
end;

pure func ReferenceBinary16FiniteValue(
    value: Word, data_type: TileDataType) => real
begin
    assert data_type == TileDataType_FP16 || data_type == TileDataType_BF16;
    let bf16 = data_type == TileDataType_BF16;
    let sign = value[15];
    let exponent = if bf16 then UInt(value[14:7])
        else UInt(value[14:10]);
    let fraction = if bf16 then UInt(value[6:0])
        else UInt(value[9:0]);
    let fraction_scale = if bf16 then 128 else 1024;
    let bias = if bf16 then 127 else 15;
    let minimum_subnormal_exponent = if bf16 then -133 else -24;
    let maximum_field = if bf16 then 255 else 31;
    assert exponent != maximum_field;
    var magnitude: real = 0.0;
    if exponent == 0 then
        magnitude = Real(fraction) * ReferencePowerOfTwo(
            minimum_subnormal_exponent as integer {-149..127});
    else
        magnitude = (1.0 + Real(fraction) / Real(fraction_scale)) *
            ReferencePowerOfTwo(
                (exponent - bias) as integer {-126..127});
    end;
    if sign == '1' then return -magnitude; end;
    return magnitude;
end;

pure func ReferenceFP8FiniteValue(
    data_type: TileDataType, code: bits(8)) => real
begin
    assert data_type == TileDataType_E4M3 ||
           data_type == TileDataType_HiF8;
    let negative = code[7] == '1';
    var magnitude: real = 0.0;
    if data_type == TileDataType_E4M3 then
        let exponent = UInt(code[6:3]);
        let fraction = UInt(code[2:0]);
        if exponent == 0 then
            magnitude = Real(fraction) * ReferencePowerOfTwo(-9);
        else
            magnitude = (1.0 + Real(fraction) / 8.0) *
                ReferencePowerOfTwo(
                    (exponent - 7) as integer {-6..8});
        end;
    else
        let body = UInt(code[6:0]);
        if body <= 7 then
            if body == 0 then magnitude = 0.0;
            else
                magnitude = ReferencePowerOfTwo(
                    (body - 23) as integer {-22..-16});
            end;
        elsif body <= 15 then
            magnitude = 1.0 + Real(body - 8) / 8.0;
        elsif body <= 31 then
            let exponent_code = UInt(code[3]);
            let exponent = if exponent_code == 0 then 1 else -1;
            magnitude = (1.0 + Real(UInt(code[2:0])) / 8.0) *
                ReferencePowerOfTwo(exponent as integer {-1..1});
        elsif body <= 63 then
            let exponent_code = UInt(code[4:3]);
            let absolute = 2 + UInt(code[3]);
            let exponent = if exponent_code < 2 then absolute else -absolute;
            magnitude = (1.0 + Real(UInt(code[2:0])) / 8.0) *
                ReferencePowerOfTwo(exponent as integer {-3..3});
        elsif body <= 95 then
            let exponent_code = UInt(code[4:2]);
            let absolute = 4 + UInt(code[3:2]);
            let exponent = if exponent_code < 4 then absolute else -absolute;
            magnitude = (1.0 + Real(UInt(code[1:0])) / 4.0) *
                ReferencePowerOfTwo(exponent as integer {-7..7});
        else
            let exponent_code = UInt(code[4:1]);
            let absolute = 8 + UInt(code[3:1]);
            let exponent = if exponent_code < 8 then absolute else -absolute;
            magnitude = (1.0 + Real(UInt(code[0])) / 2.0) *
                ReferencePowerOfTwo(exponent as integer {-15..15});
        end;
    end;
    if negative then return -magnitude; end;
    return magnitude;
end;

pure func ReferenceNearestFP8CandidateBetter(
    target: real, candidate: real, candidate_code: integer {0..255},
    best: real, best_code: integer {0..255},
    mode: NumericRoundingMode) => boolean
begin
    let candidate_distance = if candidate >= target then
        candidate - target else target - candidate;
    let best_distance = if best >= target then best - target else target - best;
    if candidate_distance < best_distance then return TRUE;
    elsif candidate_distance > best_distance then return FALSE;
    end;
    if mode == NumericRound_RNE then
        return candidate_code MOD 2 == 0 && best_code MOD 2 != 0;
    elsif mode == NumericRound_RNA then
        let candidate_magnitude = if candidate < 0.0 then -candidate else candidate;
        let best_magnitude = if best < 0.0 then -best else best;
        return candidate_magnitude > best_magnitude;
    elsif mode == NumericRound_RTO then
        return candidate_code MOD 2 != 0 && best_code MOD 2 == 0;
    else
        return candidate > best;
    end;
end;

func ReferenceFP8Encoding(
    value: real, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    assert destination_type == TileDataType_E4M3 ||
           destination_type == TileDataType_HiF8;
    if value == 0.0 then return (Zeros{PTO_XLEN}, Zeros{5}); end;
    let negative = value < 0.0;
    let magnitude = if negative then -value else value;
    let maximum = if destination_type == TileDataType_E4M3 then
        448.0 else 32768.0;
    if magnitude > maximum then
        let result = if control.saturating then
            (if destination_type == TileDataType_E4M3 then
                (if negative then 0xfe else 0x7e)
             else (if negative then 0xee else 0x6e))
        else if destination_type == TileDataType_E4M3 then 0x7f
        else if negative then 0xef else 0x6f;
        return (Zeros{PTO_XLEN} + result, Zeros{5} + 0x14);
    end;

    var best_set = FALSE;
    var best_code: integer {0..255} = 0;
    var best_value: real = 0.0;
    for code = 0 to 255 do
        let candidate_bits = Zeros{8} + code;
        let value_class = TileNumericValueClass(
            destination_type, Zeros{PTO_XLEN} + code);
        if !NumericValueClassIsNaN(value_class) &&
           !NumericValueClassIsInfinity(value_class) &&
           value_class != NumericValue_InvalidEncoding then
            let candidate = ReferenceFP8FiniteValue(
                destination_type, candidate_bits);
            var eligible = TRUE;
            if control.rounding_mode == NumericRound_RTP then
                eligible = candidate >= value;
            elsif control.rounding_mode == NumericRound_RTM then
                eligible = candidate <= value;
            elsif control.rounding_mode == NumericRound_RTZ ||
                  control.rounding_mode == NumericRound_RTO then
                eligible = if negative then candidate <= 0.0 && candidate >= value
                    else candidate >= 0.0 && candidate <= value;
            end;
            if eligible then
                var better = !best_set;
                if best_set then
                    if control.rounding_mode == NumericRound_RTP then
                        better = candidate < best_value;
                    elsif control.rounding_mode == NumericRound_RTM then
                        better = candidate > best_value;
                    elsif control.rounding_mode == NumericRound_RTZ ||
                          control.rounding_mode == NumericRound_RTO then
                        better = if negative then candidate < best_value
                            else candidate > best_value;
                    else
                        better = ReferenceNearestFP8CandidateBetter(
                            value, candidate, code, best_value, best_code,
                            control.rounding_mode);
                    end;
                end;
                if better then
                    best_set = TRUE;
                    best_code = code;
                    best_value = candidate;
                end;
            end;
        end;
    end;
    assert best_set;

    if control.rounding_mode == NumericRound_RTO && best_value != value &&
       best_code MOD 2 == 0 then
        var odd_set = FALSE;
        var odd_code: integer {0..255} = best_code;
        var odd_value: real = best_value;
        for code = 0 to 255 do
            if code MOD 2 == 1 then
                let candidate_class = TileNumericValueClass(
                    destination_type, Zeros{PTO_XLEN} + code);
                if !NumericValueClassIsNaN(candidate_class) &&
                   !NumericValueClassIsInfinity(candidate_class) then
                    let candidate = ReferenceFP8FiniteValue(
                        destination_type, Zeros{8} + code);
                    let away = if negative then candidate < best_value
                        else candidate > best_value;
                    if away && (!odd_set ||
                       (if negative then candidate > odd_value
                        else candidate < odd_value)) then
                        odd_set = TRUE;
                        odd_code = code;
                        odd_value = candidate;
                    end;
                end;
            end;
        end;
        if odd_set then
            best_code = odd_code;
            best_value = odd_value;
        end;
    end;

    let minimum_normal = if destination_type == TileDataType_E4M3 then
        ReferencePowerOfTwo(-6) else ReferencePowerOfTwo(-15);
    let inexact = best_value != value;
    let underflow = inexact && magnitude < minimum_normal;
    return (Zeros{PTO_XLEN} + best_code,
            if underflow then Zeros{5} + 0x18
            else if inexact then Zeros{5} + 0x10
            else Zeros{5});
end;

func ReferenceMatrixFloatingEncoding(
    value: real, destination_type: TileDataType,
    control: NumericExecutionControl) => (Word, bits(5))
begin
    if destination_type == TileDataType_FP32 then
        let (result, flags) = ReferenceFP32FiniteEncoding(
            value, control.rounding_mode);
        if control.saturating && (flags AND (Zeros{5} + 4)) != Zeros{5} then
            let sign = result AND (Zeros{PTO_XLEN} + 0x80000000);
            return (sign OR (Zeros{PTO_XLEN} + 0x7f7fffff), flags);
        end;
        return (result, flags);
    elsif destination_type == TileDataType_FP16 ||
          destination_type == TileDataType_BF16 then
        return ReferenceBinary16Encoding(value, destination_type, control);
    else
        return ReferenceFP8Encoding(value, destination_type, control);
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
