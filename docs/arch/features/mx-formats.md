<!-- GENERATED FROM: asl/arch/features/mx-formats.asl -->
# MX Formats

**Normative ASL source:** `asl/arch/features/mx-formats.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-MX-FORMATS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-mx-formats-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit is the named hardware numeric profile for Tile data types: `17` `pure func` declarations, no variable, no instruction body, no fault, no queue. It fixes the profile's subnormal rules, the encoding validity of four formats, value classification, canonical special values, and the comparison and min/max cases decided without arithmetic.

Line 1 declares `depends_on` `PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION`.

Design point: the unit is classified `mx-formats`, but its executable ASL defines no MX block size, no scale word and no scale-sharing rule. The raw scale word is owned by `asl/arch/data-types/formats/hif4-scale.asl`, and the only scale-adjacent type named here, `TileDataType_E8M0`, is merely classified.

<!-- PTO-READER-BLOCK: arch-mx-formats-concepts-state role=concepts-state -->
## Helpers, arguments and answers

- `HardwareNumericTypeHasSubnormals` answers TRUE for `12` of the `27` declared `TileDataType` members, among them FP64, FP32, FP16, BF16 and E4M3, and FALSE for all other types.
- `HardwareNumericInputSubnormalRule`, `HardwareNumericResultSubnormalRule` and `HardwareNumericTininessDetectionRule` map that predicate to `NumericInputSubnormal_Preserve`, `NumericResultSubnormal_GradualUnderflow` and `NumericTininessDetection_AfterRounding`, or to the matching `_NotApplicable` value.
- `TileNumericEncodingValid` is FALSE only for TF32 (`value[12:0]` nonzero), HF32 (`value[11:0]` nonzero), E3M2 and E2M3 (`value[7:6]` nonzero). `TileNumericValueClass` tests it first and answers `NumericValue_InvalidEncoding`; otherwise a `27`-arm case covering all declared types calls the per-format classifier, `ClassifySignedInteger` or `ClassifyUnsignedInteger`.
- `NumericValueClassFromFiniteSign` is declared here and called by the per-format classifiers; it answers one of `NumericValue_PositiveZero`, `NumericValue_NegativeZero`, `NumericValue_PositiveSubnormal`, `NumericValue_NegativeSubnormal`, `NumericValue_PositiveNormal` or `NumericValue_NegativeNormal`, never a NaN, an infinity or an invalid encoding.
- `HardwareNumericSubnormalBoundaries` answers availability with three raw boundary encodings, `TileNumericCanonicalNaN` with the canonical NaN (wrapped by `HardwareNumericCanonicalNaNResult`), and `HardwareNumericSignedZeroEncodings` with the two signed zero encodings.
- `HardwareNumericComparisonSpecial` and `HardwareNumericMinMaxSpecial` answer handled, a result carrier and an invalid-condition flag. `HardwareNumericMixedExpdifDiscriminator` answers handled and a result carrier; its caller is `TileProfileMixedExpdifFP32` in `asl/tile/model/execution/expdif.asl`.

<!-- PTO-READER-BLOCK: arch-mx-formats-rules-interactions role=rules-interactions -->
## Rules and interactions

`HardwareNumericSubnormalConfigurationValid` is TRUE only for the all-false triple: any TRUE among `flush_to_zero`, `denormals_are_zero` and `operation_override` makes it FALSE.

`HardwareNumericSubnormalBoundaries` answers availability TRUE for the same `12` types in `11` case arms, since E5M2 and E3M2 share one: FP32 `0x1`, `0x007fffff`, `0x00800000`; TF32 `0x00002000`, `0x007fe000`, `0x00800000`; other types answer FALSE with three zero carriers.

Comparison (`HardwareNumericComparisonSpecial`): an operand class of `NumericValue_InvalidEncoding` makes the helper answer handled FALSE. Otherwise a NaN operand makes `TileComparison_NE` answer `1` and every other comparison `0`, with invalid TRUE only for a signaling NaN; two zeros answer `1` for `TileComparison_EQ`, `TileComparison_LE` and `TileComparison_GE`, otherwise `0`.

Min/max (`HardwareNumericMinMaxSpecial`): one NaN selects the other operand's carrier unchanged, two NaNs take the canonical NaN under `assert available`, and two zeros make MIN return the `-0` operand when one exists and `0` otherwise, while MAX returns `0` unless both are `-0`, when it returns the left carrier; a signaling NaN's invalid flag comes back with a handled result.

<!-- PTO-READER-BLOCK: arch-mx-formats-boundaries role=boundaries -->
## Architectural boundaries

The unit declares no architectural state, raises no fault and touches no queue or register: every declaration is a `pure func`, and the file carries no `NDF-BEGIN` clause. Its one `assert` is the canonical-NaN check in the two-NaN min/max arm, which cannot fail: the `12` formats whose classifiers can answer `NumericValue_QuietNaN` or `NumericValue_SignalingNaN` are exactly those `TileNumericCanonicalNaN` answers TRUE for.

Design point: `Word` is a verification carrier, so bits above a type's architectural element width are ignored. `TileNumericEncodingValid` inspects `value[31:0]` for TF32 and HF32 and `value[7:0]` for E3M2 and E2M3, so nonzero bits above the element width are not rejected here.

Design point: the boolean means different things in the two helper groups: for `HardwareNumericSubnormalBoundaries`, `TileNumericCanonicalNaN` and `HardwareNumericSignedZeroEncodings`, FALSE means no value is available; for `HardwareNumericComparisonSpecial` and `HardwareNumericMinMaxSpecial`, it means the case is left to ordinary evaluation.

<!-- PTO-READER-BLOCK: arch-mx-formats-example-usage role=example-usage -->
## Non-normative reading example

For `TileDataType_TF32`, a carrier whose low `13` bits are nonzero fails `TileNumericEncodingValid`, so `TileNumericValueClass` answers `NumericValue_InvalidEncoding` and both special helpers answer handled FALSE.

`HardwareNumericSignedZeroEncodings` answers availability FALSE for `TileDataType_HiF8` while `TileNumericCanonicalNaN` answers TRUE, because the HiF8 format declares no signed zero. For one `-0` and one `0` `FP32` operand, MIN returns the `-0` carrier and MAX the `0` carrier; for an ordinary `FP32` pair with no NaN and no zero, both special helpers answer handled FALSE.

<!-- PTO-READER-BLOCK: arch-mx-formats-related-owners role=related-owners-navigation -->
## Related owners

- [Hardware numeric min/max](minmax.md) calls `HardwareNumericMinMaxSpecial` first and uses its order-key helper only when that answers handled FALSE.
- [Numeric classification](../data-types/numeric-classification.md) declares `NumericValueClass` and the rule enumerations returned here.
- [HiF4 scale format](../data-types/formats/hif4-scale.md) owns the scale word this unit does not define.
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
