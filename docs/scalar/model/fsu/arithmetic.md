<!-- GENERATED FROM: asl/scalar/model/fsu/arithmetic.asl -->
# Arithmetic

**Normative ASL source:** `asl/scalar/model/fsu/arithmetic.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-FSU-ARITHMETIC}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-purpose role=purpose-scope -->
## Purpose and scope

This unit is the real-number layer of scalar floating-point arithmetic. Most of its functions take and return mathematical `real` values or integers, not bit encodings. The unit comment states that encoding, NaN payload, exception flags, and rounding-profile rules are kept separate from this layer.

It also decodes three rounding selectors into the `NumericRoundingMode` enumeration: the scalar active mode, the bundle `RMode` field, and public conversion ordinals.

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-concepts role=concepts-state -->
## Concepts and visible state

A rounding mode says how a real value becomes a representable one. `NumericRoundingMode` has seven values:

| Mode | Meaning |
| --- | --- |
| `NumericRound_RNE` | nearest, ties to even |
| `NumericRound_RTM` | toward negative infinity |
| `NumericRound_RTP` | toward positive infinity |
| `NumericRound_RTZ` | toward zero |
| `NumericRound_RNA` | nearest, ties away from zero |
| `NumericRound_RTO` | to odd: an inexact value takes the odd neighbor |
| `NumericRound_RHB` | nearest, ties upward |

`FloatingToInteger` applies one of these modes to turn a real into an integer. The finite encoders in [reference quantization](reference-quantization.md) use it to round a scaled significand.

This unit holds no state. `ScalarFPActiveRoundingMode` in [scalar FP](scalar-fp.md) reads `CORE_STATE` bits 39:37 and passes them to `ResolveScalarFPActiveRoundingMode`.

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-rules role=rules-interactions -->
## Rules and interactions

`FloatingBinary`, `FloatingUnary`, and `FloatingFused` compute exact real results. `FloatingFused` forms the product and adds or subtracts the addend without an intermediate rounding, and the `NMADD` and `NMSUB` forms negate the whole result.

Design point: the fused result is computed once in real arithmetic and rounded once later by the encoder. That single rounding is what distinguishes `FMADD` from a separate `FMUL` then `FADD`.

`FloatingUnary` asserts that a square-root input is not negative, and computes `1.0 / value` for reciprocal. In the reference profile, the special-value layer first handles NaN, infinite, and zero inputs, and negative square-root inputs, so these calls see only the remaining finite values.

`FloatingExponential` sums the Taylor series from degree 0 through degree 18. The ASL comment calls this a fixed 18-term deterministic reference algorithm, not a promise of a host math library.

`ResolveScalarFPActiveRoundingMode` maps `001` to RTM, `010` to RTP, `011` to RTZ, and every other value, including `000` and `100` through `111`, to RNE.

Design point: every 3-bit value resolves to a defined mode. A `CORE_STATE` write is stored without checking bits 39:37, so a value other than `001`, `010`, or `011` gives RNE rather than a fault or an undefined result.

`DecodeBundleRoundingSelection` maps the bundle `RMode` field. Code `000` sets `use_operation_default`; `001` through `111` select RNE, RTZ, RTM, RTP, RNA, RTO, and RHB. `DecodePublicConversionRoundingSelection` translates public conversion ordinals 0 through 6 into bundle codes and reports ordinal 7 as unassigned.

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-boundaries role=boundaries -->
## Architectural boundaries

The scalar active selector and the bundle `RMode` field are different namespaces. The same 3-bit value means different modes in each; for example `010` is RTP for the scalar mode and RTZ for `RMode`.

`FloatingCompare`, `SignedWordToReal`, `UnsignedWordToReal`, `ConvertFloatingEncoding`, and `DecodePublicConversionRoundingSelection` have no caller in the normative `asl/` tree; only tests under `tests/asl/` call some of them. The FSU catalog names `ConvertFloatingEncoding` as the handler of the conversion forms, but decoded dispatch executes conversions through `ExecuteDecodedFPConvert`.

`DecodeBundleRoundingSelection` is used by bundle and tile units, for example `tcvt-schema` and `cube`.

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-example role=example-usage -->
## Non-normative reading example

`FloatingToInteger` on four tie and non-tie inputs:

| Input | RNE | RNA | RTO | RHB | RTZ |
| --- | --- | --- | --- | --- | --- |
| 2.5 | 2 | 3 | 3 | 3 | 2 |
| -2.5 | -2 | -3 | -3 | -2 | -2 |
| 3.5 | 4 | 4 | 3 | 4 | 3 |
| 2.25 | 2 | 2 | 3 | 2 | 2 |

For -2.5 the lower integer is -3 and the fraction is 0.5. RNE picks the even -2, RNA picks -3 because the value is negative, and RHB picks -2 because a fraction of 0.5 rounds up.

<!-- PTO-READER-BLOCK: scalar-model-fsu-arithmetic-related role=related-owners-navigation -->
## Related owners

- [Scalar FP](scalar-fp.md) reads the active mode and calls the profile hooks.
- [Reference quantization](reference-quantization.md) rounds real results into FP32, FP64, and FP16 encodings.
- [Reference special values](reference-scalar-fp-specials.md) handles NaN, infinity, and zero before this layer.
- [Numeric status](../../../arch/state/numeric-status.md) owns the sticky flags that this layer does not touch.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/fsu/arithmetic.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-FSU-ARITHMETIC","surface":"scalar","classification":["model","fsu","arithmetic"],"depends_on":["PTO-SCALAR-MODEL-SYS-REGISTERS","PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION"]}
// PTO-REQ-SCALAR-FP-001: mathematical floating semantics.
// Encoding, NaN payload, exception flag, and rounding-profile rules remain
// separate from this real-number value layer.

pure func FloatingBinary(op: FloatingBinaryOperation, left: real, right: real) => real
begin
    case op of
        when FloatingBinary_ADD => return left + right;
        when FloatingBinary_SUB => return left - right;
        when FloatingBinary_MUL => return left * right;
        when FloatingBinary_DIV => return left / right;
        when FloatingBinary_MIN => if left < right then return left; else return right; end;
        when FloatingBinary_MAX => if left > right then return left; else return right; end;
    end;
end;

pure func FloatingCompare(op: FloatingCompareOperation, left: real, right: real) => boolean
begin
    case op of
        when FloatingCompare_EQ => return left == right;
        when FloatingCompare_NE => return left != right;
        when FloatingCompare_LT => return left < right;
        when FloatingCompare_LE => return left <= right;
        when FloatingCompare_GT => return left > right;
        when FloatingCompare_GE => return left >= right;
    end;
end;

func FloatingExponential(value: real) => real
begin
    // PTO v0 fixes an 18-term Taylor reference algorithm. It is deterministic
    // executable evidence, not a promise of a host libm implementation.
    var result: real = 1.0;
    var term: real = 1.0;
    for index = 1 to 18 do
        term = (term * value) / Real(index);
        result = result + term;
    end;
    return result;
end;

func FloatingUnary(op: FloatingUnaryOperation, value: real) => real
begin
    case op of
        when FloatingUnary_ABS => if value < 0.0 then return -value; else return value; end;
        when FloatingUnary_SQRT =>
            assert value >= 0.0;
            return SqrtRounded(value, 100);
        when FloatingUnary_EXP => return FloatingExponential(value);
        when FloatingUnary_RECIP => return 1.0 / value;
    end;
end;

pure func FloatingFused(op: FloatingFusedOperation, addend: real,
                        left: real, right: real) => real
begin
    let product = left * right;
    case op of
        when FloatingFused_MADD => return product + addend;
        when FloatingFused_MSUB => return product - addend;
        when FloatingFused_NMADD => return -(product + addend);
        when FloatingFused_NMSUB => return -(product - addend);
    end;
end;

func FloatingRoundNearest(value: real) => integer
begin
    let lower = RoundDown(value);
    let fraction = value - Real(lower);
    if fraction < 0.5 then return lower;
    elsif fraction > 0.5 then return lower + 1;
    elsif lower MOD 2 == 0 then return lower;
    else return lower + 1;
    end;
end;

func FloatingToInteger(value: real, mode: NumericRoundingMode) => integer
begin
    case mode of
        when NumericRound_RNE => return FloatingRoundNearest(value);
        when NumericRound_RTP => return RoundUp(value);
        when NumericRound_RTM => return RoundDown(value);
        when NumericRound_RTZ => return RoundTowardsZero(value);
        when NumericRound_RNA =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction < 0.5 then return lower;
            elsif fraction > 0.5 then return lower + 1;
            elsif value < 0.0 then return lower;
            else return lower + 1;
            end;
        when NumericRound_RTO =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction == 0.0 then return lower;
            elsif lower MOD 2 != 0 then return lower;
            else return lower + 1;
            end;
        when NumericRound_RHB =>
            let lower = RoundDown(value);
            let fraction = value - Real(lower);
            if fraction < 0.5 then return lower;
            else return lower + 1;
            end;
    end;
end;

pure func ResolveScalarFPActiveRoundingMode(encoded: bits(3))
                                                => NumericRoundingMode
begin
    if encoded == '001' then return NumericRound_RTM;
    elsif encoded == '010' then return NumericRound_RTP;
    elsif encoded == '011' then return NumericRound_RTZ;
    else return NumericRound_RNE;
    end;
end;

pure func DecodeBundleRoundingSelection(encoded: bits(3))
                                                => TileNumericSelection
begin
    var result = TileNumericSelection {
        use_operation_default = encoded == '000',
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
    if encoded == '010' then result.rounding_mode = NumericRound_RTZ;
    elsif encoded == '011' then result.rounding_mode = NumericRound_RTM;
    elsif encoded == '100' then result.rounding_mode = NumericRound_RTP;
    elsif encoded == '101' then result.rounding_mode = NumericRound_RNA;
    elsif encoded == '110' then result.rounding_mode = NumericRound_RTO;
    elsif encoded == '111' then result.rounding_mode = NumericRound_RHB;
    end;
    return result;
end;

// Public conversion controls are not B.DATR encodings. Translate the seven
// assigned public ordinals explicitly; ordinal 7 is unassigned.
pure func DecodePublicConversionRoundingSelection(encoded: bits(3))
                                                => (boolean, TileNumericSelection)
begin
    if encoded == '000' then return (TRUE, DecodeBundleRoundingSelection('000'));
    elsif encoded == '001' then return (TRUE, DecodeBundleRoundingSelection('001'));
    elsif encoded == '010' then return (TRUE, DecodeBundleRoundingSelection('101'));
    elsif encoded == '011' then return (TRUE, DecodeBundleRoundingSelection('011'));
    elsif encoded == '100' then return (TRUE, DecodeBundleRoundingSelection('100'));
    elsif encoded == '101' then return (TRUE, DecodeBundleRoundingSelection('010'));
    elsif encoded == '110' then return (TRUE, DecodeBundleRoundingSelection('110'));
    else return (FALSE, DecodeBundleRoundingSelection('000'));
    end;
end;

pure func SignedWordToReal(value: Word) => real
begin
    return Real(SInt(value));
end;

pure func UnsignedWordToReal(value: Word) => real
begin
    return Real(UInt(value));
end;

func ConvertFloatingEncoding(value: Word, source_type: bits(5),
                             destination_type: bits(5),
                             rounding_mode: bits(3)) => Word
begin
    let (converted, -) = ScalarFPConvertProfile(
        ResolveScalarFPActiveRoundingMode(rounding_mode),
        destination_type, source_type, value);
    return converted;
end;
```
<!-- GENERATED-ASL-END: unit -->
