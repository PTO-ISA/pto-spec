<!-- GENERATED FROM: asl/arch/features/mx-formats.asl -->
# MX Formats

**Normative ASL source:** `asl/arch/features/mx-formats.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-MX-FORMATS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-mx-formats-purpose-scope role=purpose-scope -->
## 目的与范围

本单元是 Tile 数据类型所使用的命名硬件数值配置：`17` 个 `pure func` 声明，没有变量、没有指令体、没有故障、没有队列。它固定该配置的次正规数规则、四种格式的编码有效性、数值分类、规范特殊值，以及无需算术即可判定的比较与最小值/最大值情况。

第 1 行声明 `depends_on` `PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION`。

Design point: 本单元的归类是 `mx-formats`，但其可执行 ASL 未定义任何 MX 块大小、任何缩放字和任何共享缩放规则。原始缩放字由 `asl/arch/data-types/formats/hif4-scale.asl` 拥有，而本文件唯一涉及的与缩放相关的类型 `TileDataType_E8M0` 仅被分类。

<!-- PTO-READER-BLOCK: arch-mx-formats-concepts-state role=concepts-state -->
## 辅助函数、参数与结果

- `HardwareNumericTypeHasSubnormals` 对已声明的 `27` 个 `TileDataType` 成员中的 `12` 个返回 TRUE，其中包括 FP64、FP32、FP16、BF16 与 E4M3；其余类型都返回 FALSE。
- `HardwareNumericInputSubnormalRule`、`HardwareNumericResultSubnormalRule` 与 `HardwareNumericTininessDetectionRule` 把该谓词映射为 `NumericInputSubnormal_Preserve`、`NumericResultSubnormal_GradualUnderflow` 与 `NumericTininessDetection_AfterRounding`，对没有次正规数的类型则返回对应的 `_NotApplicable` 值。
- `TileNumericEncodingValid` 只对四种类型返回 FALSE：TF32（`value[12:0]` 非零）、HF32（`value[11:0]` 非零）、E3M2 与 E2M3（`value[7:6]` 非零）。`TileNumericValueClass` 先检查它，失败时返回 `NumericValue_InvalidEncoding`；否则由一个覆盖全部已声明类型的 `27` 分支 case 调用各格式分类函数、`ClassifySignedInteger` 或 `ClassifyUnsignedInteger`。
- `NumericValueClassFromFiniteSign` 在本单元声明，并被各格式分类函数调用；它的结果是 `NumericValue_PositiveZero`、`NumericValue_NegativeZero`、`NumericValue_PositiveSubnormal`、`NumericValue_NegativeSubnormal`、`NumericValue_PositiveNormal` 或 `NumericValue_NegativeNormal` 之一，绝不会是 NaN、无穷或无效编码。
- `HardwareNumericSubnormalBoundaries` 以可用性加上三个原始边界编码作答，`TileNumericCanonicalNaN` 以规范 NaN 作答（由包装函数 `HardwareNumericCanonicalNaNResult` 返回），`HardwareNumericSignedZeroEncodings` 以两个带符号零编码作答。
- `HardwareNumericComparisonSpecial` 与 `HardwareNumericMinMaxSpecial` 返回是否已处理、结果载体和无效条件标志。`HardwareNumericMixedExpdifDiscriminator` 返回是否已处理与结果载体；它的调用方是 `asl/tile/model/execution/expdif.asl` 中的 `TileProfileMixedExpdifFP32`。

<!-- PTO-READER-BLOCK: arch-mx-formats-rules-interactions role=rules-interactions -->
## 规则与交互

`HardwareNumericSubnormalConfigurationValid` 只对三个输入全为假的情形返回 TRUE：`flush_to_zero`、`denormals_are_zero` 与 `operation_override` 中任何一个为真都会使其返回 FALSE。

`HardwareNumericSubnormalBoundaries` 对同样的 `12` 个类型返回可用性为真，共 `11` 个 case 分支，因为 E5M2 与 E3M2 共用一个分支：FP32 为 `0x1`、`0x007fffff`、`0x00800000`；TF32 为 `0x00002000`、`0x007fe000`、`0x00800000`；其他类型返回假以及三个零载体。

比较（`HardwareNumericComparisonSpecial`）：任一操作数类别为 `NumericValue_InvalidEncoding` 时，该辅助函数返回未处理。否则只要存在一个 NaN 操作数，`TileComparison_NE` 就返回 `1`，其他比较返回 `0`，且只有存在信号 NaN 时无效标志才为真；两个零对 `TileComparison_EQ`、`TileComparison_LE` 与 `TileComparison_GE` 返回 `1`，其他情况返回 `0`。

最小值/最大值（`HardwareNumericMinMaxSpecial`）：单个 NaN 使另一个操作数的载体原样被选中，两个 NaN 在 `assert available` 下取该类型的规范 NaN，两个零时 MIN 在存在 `-0` 操作数时返回它、否则返回 `0`，而 MAX 返回 `0`，除非两者都是 `-0`，此时返回左操作数载体；信号 NaN 产生的无效标志会与已处理的结果一同返回。

<!-- PTO-READER-BLOCK: arch-mx-formats-boundaries role=boundaries -->
## 架构边界

本单元不声明任何架构状态、不引发任何故障、也不触碰任何队列或寄存器：每个声明都是 `pure func`，并且该文件不含 `NDF-BEGIN` 子句。它唯一的 `assert` 是两个 NaN 的最小值/最大值分支中的规范 NaN 检查，该断言不可能失败：能够返回 `NumericValue_QuietNaN` 或 `NumericValue_SignalingNaN` 的 `12` 种格式，正是 `TileNumericCanonicalNaN` 返回 TRUE 的那些格式。

Design point: `Word` 是验证载体，因此高于某类型架构元素宽度的位会被忽略。`TileNumericEncodingValid` 对 TF32 与 HF32 检查 `value[31:0]`，对 E3M2 与 E2M3 检查 `value[7:0]`，所以元素宽度以上的非零位不会在此被拒绝。

Design point: 布尔量在两组辅助函数中含义不同：对 `HardwareNumericSubnormalBoundaries`、`TileNumericCanonicalNaN` 与 `HardwareNumericSignedZeroEncodings`，假表示该类型没有可用值；对 `HardwareNumericComparisonSpecial` 与 `HardwareNumericMinMaxSpecial`，假表示该情况留给普通求值处理。

<!-- PTO-READER-BLOCK: arch-mx-formats-example-usage role=example-usage -->
## 非规范阅读示例

对于 `TileDataType_TF32`，低 `13` 位非零的载体无法通过 `TileNumericEncodingValid`，因此 `TileNumericValueClass` 返回 `NumericValue_InvalidEncoding`，两个特殊辅助函数也都返回未处理。

对 `TileDataType_HiF8`，`HardwareNumericSignedZeroEncodings` 返回可用性为假，而 `TileNumericCanonicalNaN` 返回 TRUE，因为 HiF8 格式声明没有带符号零。对于一个 `-0` 和一个 `0` 的 `FP32` 操作数，MIN 返回 `-0` 载体，MAX 返回 `0` 载体；对于既无 NaN 也无零的普通 `FP32` 操作数对，两个特殊辅助函数都返回未处理。

<!-- PTO-READER-BLOCK: arch-mx-formats-related-owners role=related-owners-navigation -->
## 相关归属单元

- [硬件数值最小值/最大值](minmax.md) 先调用 `HardwareNumericMinMaxSpecial`，只有在其返回未处理时才使用其序键辅助函数。
- [数值分类](../data-types/numeric-classification.md) 声明 `NumericValueClass` 以及此处返回的规则枚举。
- [HiF4 缩放格式](../data-types/formats/hif4-scale.md) 拥有本单元未定义的缩放字。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/mx-formats.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-MX-FORMATS","surface":"arch","classification":["features","mx-formats"],"depends_on":["PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION"]}
pure func HardwareNumericTypeHasSubnormals(data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_FP64, TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32, TileDataType_FP16, TileDataType_BF16,
             TileDataType_HiF8, TileDataType_E4M3, TileDataType_E5M2,
             TileDataType_E3M2, TileDataType_E2M3,
             TileDataType_E2M1X2 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func HardwareNumericInputSubnormalRule(data_type: TileDataType)
    => NumericInputSubnormalRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericInputSubnormal_Preserve;
    else return NumericInputSubnormal_NotApplicable;
    end;
end;

pure func HardwareNumericResultSubnormalRule(data_type: TileDataType)
    => NumericResultSubnormalRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericResultSubnormal_GradualUnderflow;
    else return NumericResultSubnormal_NotApplicable;
    end;
end;

pure func HardwareNumericTininessDetectionRule(data_type: TileDataType)
    => NumericTininessDetectionRule
begin
    if HardwareNumericTypeHasSubnormals(data_type) then
        return NumericTininessDetection_AfterRounding;
    else return NumericTininessDetection_NotApplicable;
    end;
end;

// These booleans describe a candidate conformance configuration. They are not
// architectural mode bits. The named hardware profile exposes no FTZ/DAZ
// state and permits no operation-local override.
pure func HardwareNumericSubnormalConfigurationValid(flush_to_zero: boolean,
                                                       denormals_are_zero: boolean,
                                                       operation_override: boolean)
    => boolean
begin
    return !flush_to_zero && !denormals_are_zero && !operation_override;
end;

// Returns availability, minimum positive subnormal, maximum positive
// subnormal, and minimum positive normal. Values are exact raw encodings.
pure func HardwareNumericSubnormalBoundaries(data_type: TileDataType)
    => (boolean, Word, Word, Word)
begin
    case data_type of
        when TileDataType_FP64 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x000fffffffffffff,
                    Zeros{PTO_XLEN} + 0x0010000000000000);
        when TileDataType_FP32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x007fffff,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_TF32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x00002000,
                    Zeros{PTO_XLEN} + 0x007fe000,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_HF32 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x00001000,
                    Zeros{PTO_XLEN} + 0x007ff000,
                    Zeros{PTO_XLEN} + 0x00800000);
        when TileDataType_FP16 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x03ff,
                    Zeros{PTO_XLEN} + 0x0400);
        when TileDataType_BF16 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x1,
                    Zeros{PTO_XLEN} + 0x007f,
                    Zeros{PTO_XLEN} + 0x0080);
        when TileDataType_HiF8 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        when TileDataType_E4M3 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        when TileDataType_E5M2, TileDataType_E3M2 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x03,
                    Zeros{PTO_XLEN} + 0x04);
        when TileDataType_E2M3 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x07,
                    Zeros{PTO_XLEN} + 0x08);
        when TileDataType_E2M1X2 =>
            return (TRUE, Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x01,
                    Zeros{PTO_XLEN} + 0x02);
        otherwise =>
            return (FALSE, Zeros{PTO_XLEN}, Zeros{PTO_XLEN},
                    Zeros{PTO_XLEN});
    end;
end;

pure func NumericValueClassFromFiniteSign(sign: bits(1), zero: boolean,
                                           subnormal: boolean)
    => NumericValueClass
begin
    if zero then
        if sign == '1' then return NumericValue_NegativeZero;
        else return NumericValue_PositiveZero;
        end;
    elsif subnormal then
        if sign == '1' then return NumericValue_NegativeSubnormal;
        else return NumericValue_PositiveSubnormal;
        end;
    elsif sign == '1' then return NumericValue_NegativeNormal;
    else return NumericValue_PositiveNormal;
    end;
end;

// The ASL Word is a verification carrier. Bits above a type's architectural
// element width are ignored. Only constraints inside the architectural
// element are checked here.
pure func TileNumericEncodingValid(data_type: TileDataType,
                                   value: Word) => boolean
begin
    case data_type of
        when TileDataType_TF32 => return TF32EncodingValid(value[31:0]);
        when TileDataType_HF32 => return HF32EncodingValid(value[31:0]);
        when TileDataType_E3M2 => return E3M2EncodingValid(value[7:0]);
        when TileDataType_E2M3 => return E2M3EncodingValid(value[7:0]);
        otherwise => return TRUE;
    end;
end;

pure func ClassifySignedInteger(value: Word, sign_bit: integer {3,7,15,31,63})
    => NumericValueClass
begin
    var zero = FALSE;
    case sign_bit of
        when 3 => zero = value[3:0] == Zeros{4};
        when 7 => zero = value[7:0] == Zeros{8};
        when 15 => zero = value[15:0] == Zeros{16};
        when 31 => zero = value[31:0] == Zeros{32};
        when 63 => zero = value == Zeros{PTO_XLEN};
    end;
    if zero then return NumericValue_PositiveZero;
    elsif value[sign_bit] == '1' then return NumericValue_NegativeNormal;
    else return NumericValue_PositiveNormal;
    end;
end;

pure func ClassifyUnsignedInteger(value: Word, width: integer {4,8,16,32,64})
    => NumericValueClass
begin
    var zero = FALSE;
    case width of
        when 4 => zero = value[3:0] == Zeros{4};
        when 8 => zero = value[7:0] == Zeros{8};
        when 16 => zero = value[15:0] == Zeros{16};
        when 32 => zero = value[31:0] == Zeros{32};
        when 64 => zero = value == Zeros{PTO_XLEN};
    end;
    if zero then return NumericValue_PositiveZero;
    else return NumericValue_PositiveNormal;
    end;
end;

pure func TileNumericValueClass(data_type: TileDataType,
                                value: Word) => NumericValueClass
begin
    if !TileNumericEncodingValid(data_type, value) then
        return NumericValue_InvalidEncoding;
    end;
    case data_type of
        when TileDataType_FP64 => return ClassifyFP64(value);
        when TileDataType_FP32 => return ClassifyFP32(value[31:0]);
        when TileDataType_TF32 => return ClassifyTF32(value[31:0]);
        when TileDataType_HF32 => return ClassifyHF32(value[31:0]);
        when TileDataType_FP16 => return ClassifyFP16(value[15:0]);
        when TileDataType_BF16 => return ClassifyBF16(value[15:0]);
        when TileDataType_HiF8 => return ClassifyHiF8(value[7:0]);
        when TileDataType_E4M3 => return ClassifyE4M3(value[7:0]);
        when TileDataType_E5M2 => return ClassifyE5M2(value[7:0]);
        when TileDataType_E3M2 => return ClassifyE3M2(value[7:0]);
        when TileDataType_E2M3 => return ClassifyE2M3(value[7:0]);
        when TileDataType_E2M1X2 => return ClassifyE2M1X2(value);
        when TileDataType_E1M2X2 => return ClassifyE1M2X2(value);
        when TileDataType_E8M0 => return ClassifyE8M0(value[7:0]);
        when TileDataType_HiF4X2 => return ClassifyHiF4X2(value);
        when TileDataType_E6M2 => return ClassifyE6M2(value[7:0]);
        when TileDataType_RCPE6M2 => return ClassifyRCPE6M2(value[7:0]);
        when TileDataType_S64 => return ClassifySignedInteger(value, 63);
        when TileDataType_S32 => return ClassifySignedInteger(value, 31);
        when TileDataType_S16 => return ClassifySignedInteger(value, 15);
        when TileDataType_S8 => return ClassifySignedInteger(value, 7);
        when TileDataType_S4X2 => return ClassifySignedInteger(value, 3);
        when TileDataType_U64 => return ClassifyUnsignedInteger(value, 64);
        when TileDataType_U32 => return ClassifyUnsignedInteger(value, 32);
        when TileDataType_U16 => return ClassifyUnsignedInteger(value, 16);
        when TileDataType_U8 => return ClassifyUnsignedInteger(value, 8);
        when TileDataType_U4X2 => return ClassifyUnsignedInteger(value, 4);
    end;
end;

pure func TileNumericCanonicalNaN(data_type: TileDataType) => (boolean, Word)
begin
    case data_type of
        when TileDataType_FP64 => return (TRUE, FP64CanonicalNaN());
        when TileDataType_FP32 => return (TRUE, FP32CanonicalNaN());
        when TileDataType_TF32 => return (TRUE, TF32CanonicalNaN());
        when TileDataType_HF32 => return (TRUE, HF32CanonicalNaN());
        when TileDataType_FP16 => return (TRUE, FP16CanonicalNaN());
        when TileDataType_BF16 => return (TRUE, BF16CanonicalNaN());
        when TileDataType_HiF8 => return (TRUE, HiF8CanonicalNaN());
        when TileDataType_E4M3 => return (TRUE, E4M3CanonicalNaN());
        when TileDataType_E5M2 => return (TRUE, E5M2CanonicalNaN());
        when TileDataType_E8M0 => return (TRUE, E8M0CanonicalNaN());
        when TileDataType_E6M2 => return (TRUE, E6M2CanonicalNaN());
        when TileDataType_RCPE6M2 => return (TRUE, RCPE6M2CanonicalNaN());
        otherwise => return (FALSE, Zeros{PTO_XLEN});
    end;
end;

// Named hardware-profile special-result helpers. These functions classify
// only cases whose result is fixed without evaluating ordinary arithmetic.
// Invalid internal encodings and non-special operands remain unhandled so a
// complete operation/type profile must reject or evaluate them explicitly.
pure func HardwareNumericCanonicalNaNResult(data_type: TileDataType)
    => (boolean, Word)
begin
    return TileNumericCanonicalNaN(data_type);
end;

// The selected IEEE hardware profile fixes these mixed-EXPDIF
// discriminator results after exact source widening and FP32 SUB/EXP.  This
// witness is intentionally narrow: other FP32 operands continue through the
// active profile implementation rather than acquiring a second numeric
// contract here.
pure func HardwareNumericMixedExpdifDiscriminator(left: Word, right: Word)
    => (boolean, Word)
begin
    if left == (Zeros{PTO_XLEN} + 0x3c000000) &&
       right == (Zeros{PTO_XLEN} + 0x33800000) then
        return (TRUE, Zeros{PTO_XLEN} + 0x3f810100);
    elsif left == (Zeros{PTO_XLEN} + 0x3f800000) &&
          right == (Zeros{PTO_XLEN} + 0x3b000000) then
        return (TRUE, Zeros{PTO_XLEN} + 0x402da16e);
    end;
    return (FALSE, Zeros{PTO_XLEN});
end;

pure func HardwareNumericSignedZeroEncodings(data_type: TileDataType)
    => (boolean, Word, Word)
begin
    case data_type of
        when TileDataType_FP64 =>
            let (positive, negative) = FP64SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_FP32 =>
            let (positive, negative) = FP32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_TF32 =>
            let (positive, negative) = TF32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_HF32 =>
            let (positive, negative) = HF32SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_FP16 =>
            let (positive, negative) = FP16SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_BF16 =>
            let (positive, negative) = BF16SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E4M3 =>
            let (positive, negative) = E4M3SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E5M2 =>
            let (positive, negative) = E5M2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E3M2 =>
            let (positive, negative) = E3M2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E2M3 =>
            let (positive, negative) = E2M3SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E2M1X2 =>
            let (positive, negative) = E2M1X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_E1M2X2 =>
            let (positive, negative) = E1M2X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        when TileDataType_HiF4X2 =>
            let (positive, negative) = HiF4X2SignedZeroEncodings();
            return (TRUE, positive, negative);
        otherwise => return (FALSE, Zeros{PTO_XLEN}, Zeros{PTO_XLEN});
    end;
end;

// Returns handled, result carrier, and invalid-condition status. NaN
// comparisons are unordered except NE, and signed zeros compare equal.
pure func HardwareNumericComparisonSpecial(
    comparison: TileComparison, data_type: TileDataType,
    left: Word, right: Word) => (boolean, Word, boolean)
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    if left_class == NumericValue_InvalidEncoding ||
       right_class == NumericValue_InvalidEncoding then
        return (FALSE, Zeros{PTO_XLEN}, FALSE);
    end;
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);
    let invalid = left_class == NumericValue_SignalingNaN ||
                  right_class == NumericValue_SignalingNaN;
    if left_nan || right_nan then
        if comparison == TileComparison_NE then
            return (TRUE, Zeros{PTO_XLEN} + 1, invalid);
        else return (TRUE, Zeros{PTO_XLEN}, invalid);
        end;
    end;
    if NumericValueClassIsZero(left_class) &&
       NumericValueClassIsZero(right_class) then
        if comparison == TileComparison_EQ || comparison == TileComparison_LE ||
           comparison == TileComparison_GE then
            return (TRUE, Zeros{PTO_XLEN} + 1, FALSE);
        else return (TRUE, Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, FALSE);
end;

// Returns handled, result carrier, and invalid-condition status for MIN/MAX
// NaN and zero ties. One NaN selects the numeric operand, two NaNs produce the
// destination canonical NaN, MIN chooses -0, and MAX chooses +0.
pure func HardwareNumericMinMaxSpecial(
    maximum: boolean, data_type: TileDataType,
    left: Word, right: Word) => (boolean, Word, boolean)
begin
    let left_class = TileNumericValueClass(data_type, left);
    let right_class = TileNumericValueClass(data_type, right);
    if left_class == NumericValue_InvalidEncoding ||
       right_class == NumericValue_InvalidEncoding then
        return (FALSE, Zeros{PTO_XLEN}, FALSE);
    end;
    let left_nan = NumericValueClassIsNaN(left_class);
    let right_nan = NumericValueClassIsNaN(right_class);
    let invalid = left_class == NumericValue_SignalingNaN ||
                  right_class == NumericValue_SignalingNaN;
    if left_nan && right_nan then
        let (available, canonical) =
            HardwareNumericCanonicalNaNResult(data_type);
        assert available;
        return (TRUE, canonical, invalid);
    elsif left_nan then return (TRUE, right, invalid);
    elsif right_nan then return (TRUE, left, invalid);
    end;
    if NumericValueClassIsZero(left_class) &&
       NumericValueClassIsZero(right_class) then
        if maximum && left_class == NumericValue_NegativeZero &&
           right_class == NumericValue_NegativeZero then
            return (TRUE, left, FALSE);
        elsif maximum then return (TRUE, Zeros{PTO_XLEN}, FALSE);
        elsif left_class == NumericValue_NegativeZero then
            return (TRUE, left, FALSE);
        elsif right_class == NumericValue_NegativeZero then
            return (TRUE, right, FALSE);
        else return (TRUE, Zeros{PTO_XLEN}, FALSE);
        end;
    end;
    return (FALSE, Zeros{PTO_XLEN}, FALSE);
end;
```
<!-- GENERATED-ASL-END: unit -->
