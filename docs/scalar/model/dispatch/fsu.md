<!-- GENERATED FROM: asl/scalar/model/dispatch/fsu.asl -->
# FSU

**Normative ASL source:** `asl/scalar/model/dispatch/fsu.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-FSU}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-purpose role=purpose-scope -->
## Purpose and scope

This unit executes every decoded scalar floating-point (FSU) form. `ExecuteDecodedFSUForm` maps each operation to one of five helpers:

- `ExecuteDecodedFPUnary` for `FABS`, `FEXP`, `FRECIP`, and `FSQRT`;
- `ExecuteDecodedFPBinary` for `FADD`, `FSUB`, `FMUL`, `FDIV`, `FMIN`, and `FMAX`;
- `ExecuteDecodedFPCompare` for the eight comparisons;
- `ExecuteDecodedFPFused` for `FMADD`, `FMSUB`, `FNMADD`, and `FNMSUB`;
- `ExecuteDecodedFPConvert` for `FCVT`, `FCVTA`, `FCVTM`, `FCVTN`, `FCVTP`, `FCVTZ`, `SCVTF`, and `UCVTF`.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-concepts role=concepts-state -->
## Concepts and visible state

A carrier is the 64-bit register word (a GPR or a T/U entry) that holds a floating value. The 2-bit `SrcType` field selects it. For arithmetic, `00` means FP64 in the whole word and `01` means FP32 in bits 31:0. `NormalizeScalarFPSource` zero-extends an FP32 carrier, so bits 63:32 of the source are ignored.

For conversions the same 2-bit field names four source types. Floating conversions use FP64, FP32, FP16, and E4M3. `SCVTF` uses S64, S32, S16, and S8; `UCVTF` uses U64, U32, U16, and U8. The 5-bit `DstType` field names the destination type.

Two pieces of `CORE_STATE` matter:

- bits 39:37 select the active rounding mode, read by `ScalarFPActiveRoundingMode`;
- bits 36:32 hold the sticky flags NV, DZ, OF, UF, and NX, updated by `ScalarFPRecordFlags`.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-rules role=rules-interactions -->
## Rules and interactions

Every helper first checks the source type, and conversions also check the destination type. An unsupported type raises `Fault_IllegalInstruction` and returns before any source register is read.

Design point: type legality comes before the first source read. A rejected FSU instruction therefore reads no T/U entry, calls no numeric profile, writes no flag, and writes no destination. The catalog constrains `SrcType` to 0 or 1 for the arithmetic, comparison, and fused forms and `DstType` to supported codes for the conversions, so on the decoded path `ScalarFormOperandsLegal` already rejects every code that the in-helper check would reject.

After the check, a helper reads its sources, computes the result and a 5-bit flag vector, ORs the flags into `CORE_STATE`, and writes the destination.

Some rules are fixed in this unit rather than in a profile:

- `FABS` clears the carrier's sign bit and records no flags.
- `FMIN` and `FMAX` use `ScalarFPMinMax`. They record NV only when an input is a signaling NaN.
- Comparisons are ordered. Any NaN input makes the result 0, even for `FNE`. Quiet forms record NV only for a signaling NaN; signaling forms (`FEQS`, `FNES`, `FLTS`, `FGES`) record NV for any NaN. The result is the word 0 or 1.

Design point: flags are ORed into the old value and never cleared by an operation. A later read of `CORE_STATE` therefore shows the union of the flags produced since `CORE_STATE` was last written as a whole, for example by a system-register write, reset, or trap-context recovery.

Arithmetic and `FCVT`, `SCVTF`, and `UCVTF` use the active rounding mode. `FCVTA`, `FCVTM`, `FCVTN`, `FCVTP`, and `FCVTZ` ignore it and use RNA, RTM, RNE, RTP, and RTZ respectively.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-boundaries role=boundaries -->
## Architectural boundaries

Numeric results come from profile hooks in [scalar FP](../fsu/scalar-fp.md), such as `ScalarFPBinaryProfile` and `ScalarFPConvertProfile`. The arithmetic profiles use the quantization and special-value units; the conversion profiles use `ReferenceCommonConvert` from [reference conversion](../../../tile/model/numeric/reference-conversion.md).

Numeric flags do not raise a trap. The only fault this unit raises is `Fault_IllegalInstruction` for an unsupported type; unavailable T/U sources are rejected earlier by top-level dispatch.

Float-to-integer `DstType` codes 0 through 3 select U64, U32, U16, and U8; codes 4 through 7 select S64, S32, S16, and S8.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-example role=example-usage -->
## Non-normative reading example

Take the 32-bit word 0x027302CB. It matches `FADD` (mask 0xF800707F, match 0x4B).

| Field | Bits | Raw | Meaning |
| --- | --- | --- | --- |
| `RegDst` | 11:7 | 5 | GPR 5 |
| `SrcL` | 19:15 | 6 | GPR 6 |
| `SrcR` | 24:20 | 7 | GPR 7 |
| `SrcType` | 26:25 | `01` | FP32 |

Let GPR 6 hold 0xDEADBEEF3F800000 and GPR 7 hold 0x40000000. Only bits 31:0 are used, so the inputs are 1.0 and 2.0. With the active mode RNE the sum 3.0 is exact. GPR 5 receives 0x0000000040400000, and no flag is recorded.

<!-- PTO-READER-BLOCK: scalar-model-dispatch-fsu-related role=related-owners-navigation -->
## Related owners

- [Scalar FP](../fsu/scalar-fp.md) owns carriers, type codes, comparison, min/max, and profile hooks.
- [FSU arithmetic](../fsu/arithmetic.md) owns the real-number operations and rounding decode.
- [Reference special values](../fsu/reference-scalar-fp-specials.md) owns NaN, infinity, and zero results.
- [Numeric status](../../../arch/state/numeric-status.md) owns the sticky flag field.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/fsu.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-FSU","surface":"scalar","classification":["model","dispatch","fsu"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-FSU-SCALAR-FP","PTO-SCALAR-FABS","PTO-SCALAR-FADD","PTO-SCALAR-FCVT","PTO-SCALAR-FCVTA","PTO-SCALAR-FCVTM","PTO-SCALAR-FCVTN","PTO-SCALAR-FCVTP","PTO-SCALAR-FCVTZ","PTO-SCALAR-FDIV","PTO-SCALAR-FEQ","PTO-SCALAR-FEQS","PTO-SCALAR-FEXP","PTO-SCALAR-FGE","PTO-SCALAR-FGES","PTO-SCALAR-FLT","PTO-SCALAR-FLTS","PTO-SCALAR-FMADD","PTO-SCALAR-FMAX","PTO-SCALAR-FMIN","PTO-SCALAR-FMSUB","PTO-SCALAR-FMUL","PTO-SCALAR-FNE","PTO-SCALAR-FNES","PTO-SCALAR-FNMADD","PTO-SCALAR-FNMSUB","PTO-SCALAR-FRECIP","PTO-SCALAR-FSQRT","PTO-SCALAR-FSUB","PTO-SCALAR-SCVTF","PTO-SCALAR-UCVTF"]}
pure func ScalarDecodedFPSourceType(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1}) => bits(2)
begin
    return DecodeScalarOperandRaw(instruction, form, ScalarField_SrcType)[1:0];
end;

func ExecuteDecodedFPBinary(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: FloatingBinaryOperation)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let source_type = ScalarFPSourceTypeCode(source_selector);
    if !ScalarFPTypeCodeSupported(source_type) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let left = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        source_type);
    let right = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        source_type);
    var result: Word;
    var flags: bits(5);
    if operation == FloatingBinary_MIN || operation == FloatingBinary_MAX then
        result = ScalarFPMinMax(operation, left, right, source_selector);
        flags = if ScalarFPIsSignalingNaN(left, source_selector) ||
                   ScalarFPIsSignalingNaN(right, source_selector)
                then Zeros{5} + 1 else Zeros{5};
    else
        (result, flags) = ScalarFPBinaryProfile(
            operation, ScalarFPActiveRoundingMode(), source_type, left, right);
    end;
    ScalarFPRecordFlags(flags);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        NormalizeScalarFPResult(result, source_type));
end;

func ExecuteDecodedFPUnary(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: FloatingUnaryOperation)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let source_type = ScalarFPSourceTypeCode(source_selector);
    if !ScalarFPTypeCodeSupported(source_type) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let value = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        source_type);
    var result: Word;
    var flags: bits(5);
    if operation == FloatingUnary_ABS then
        if source_selector == '01' then
            result = ZeroExtend{PTO_XLEN}(
                value[31:0] AND (Zeros{32} + 0x7fffffff));
        else
            result = value AND (Zeros{PTO_XLEN} + 0x7fffffffffffffff);
        end;
        flags = Zeros{5};
    else
        (result, flags) = ScalarFPUnaryProfile(
            operation, ScalarFPActiveRoundingMode(), source_type, value);
    end;
    ScalarFPRecordFlags(flags);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        NormalizeScalarFPResult(result, source_type));
end;

func ExecuteDecodedFPCompare(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: FloatingCompareOperation, signaling: boolean)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let source_type = ScalarFPSourceTypeCode(source_selector);
    if !ScalarFPTypeCodeSupported(source_type) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let left = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        source_type);
    let right = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        source_type);
    let any_nan = ScalarFPIsNaN(left, source_selector) ||
                  ScalarFPIsNaN(right, source_selector);
    let any_signaling_nan = ScalarFPIsSignalingNaN(left, source_selector) ||
                            ScalarFPIsSignalingNaN(right, source_selector);
    if (signaling && any_nan) || any_signaling_nan then
        ScalarFPRecordFlags(Zeros{5} + 1);
    end;
    let comparison = ScalarFPEncodingCompare(
        operation, left, right, source_selector);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        if comparison then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
end;

func ExecuteDecodedFPFused(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: FloatingFusedOperation)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let source_type = ScalarFPSourceTypeCode(source_selector);
    if !ScalarFPTypeCodeSupported(source_type) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;
    let addend = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcA),
        source_type);
    let left = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        source_type);
    let right = NormalizeScalarFPSource(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        source_type);
    let (result, flags) = ScalarFPFusedProfile(
        operation, ScalarFPActiveRoundingMode(), source_type,
        addend, left, right);
    ScalarFPRecordFlags(flags);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        NormalizeScalarFPResult(result, source_type));
end;

func ExecuteDecodedFPConvert(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: ScalarOperation)
begin
    let source_selector = ScalarDecodedFPSourceType(instruction, form);
    let raw_destination_type = ScalarDecodedBits5(
        instruction, form, ScalarField_DstType);
    var source_type: bits(5);
    var destination_type: bits(5);
    var source_supported: boolean;
    var destination_supported: boolean;
    if operation == ScalarOperation_SCVTF then
        source_type = ScalarSignedIntegerSourceTypeCode(source_selector);
        destination_type = raw_destination_type;
        source_supported = ScalarConvertIntegerTypeCodeSupported(source_type);
        destination_supported =
            ScalarConvertFloatingTypeCodeSupported(destination_type);
    elsif operation == ScalarOperation_UCVTF then
        source_type = ScalarUnsignedIntegerSourceTypeCode(source_selector);
        destination_type = raw_destination_type;
        source_supported = ScalarConvertIntegerTypeCodeSupported(source_type);
        destination_supported =
            ScalarConvertFloatingTypeCodeSupported(destination_type);
    else
        source_type = ScalarConvertFloatingTypeCode(source_selector);
        source_supported =
            ScalarConvertFloatingTypeCodeSupported(source_type);
        if operation == ScalarOperation_FCVT then
            destination_type = raw_destination_type;
            destination_supported =
                ScalarConvertFloatingTypeCodeSupported(destination_type);
        else
            destination_type = ScalarFPToIntegerDestinationTypeCode(
                raw_destination_type);
            destination_supported =
                ScalarConvertIntegerTypeCodeSupported(destination_type);
        end;
    end;
    if !source_supported || !destination_supported then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return;
    end;

    // Type legality is resolved before this first architectural source read.
    let value = ReadDecodedScalarRegister(
        instruction, form, ScalarField_SrcL);
    var result: Word;
    var flags: bits(5);
    if operation == ScalarOperation_FCVT then
        (result, flags) = ScalarFPConvertProfile(
            ScalarFPActiveRoundingMode(), destination_type, source_type,
            NormalizeScalarConvertFloating(value, source_type));
        result = NormalizeScalarConvertFloating(
            result, destination_type);
    elsif operation == ScalarOperation_SCVTF ||
          operation == ScalarOperation_UCVTF then
        (result, flags) = ScalarIntegerToFPProfile(
            ScalarFPActiveRoundingMode(), source_type, destination_type,
            NormalizeScalarIntegerSource(value, source_type));
        result = NormalizeScalarConvertFloating(
            result, destination_type);
    else
        let rounding_mode = ScalarFPFixedConversionRoundingMode(operation);
        (result, flags) = ScalarFPToIntegerProfile(
            rounding_mode, destination_type, source_type,
            NormalizeScalarConvertFloating(value, source_type));
        result = NormalizeScalarIntegerResult(result, destination_type);
    end;
    ScalarFPRecordFlags(flags);
    WriteScalarDestination(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst), result);
end;

func ExecuteDecodedFSUForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_FABS =>
            ExecuteDecodedFPUnary(instruction, form, FloatingUnary_ABS);
        when ScalarOperation_FEXP =>
            ExecuteDecodedFPUnary(instruction, form, FloatingUnary_EXP);
        when ScalarOperation_FRECIP =>
            ExecuteDecodedFPUnary(instruction, form, FloatingUnary_RECIP);
        when ScalarOperation_FSQRT =>
            ExecuteDecodedFPUnary(instruction, form, FloatingUnary_SQRT);
        when ScalarOperation_FADD =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_ADD);
        when ScalarOperation_FSUB =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_SUB);
        when ScalarOperation_FMUL =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_MUL);
        when ScalarOperation_FDIV =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_DIV);
        when ScalarOperation_FMIN =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_MIN);
        when ScalarOperation_FMAX =>
            ExecuteDecodedFPBinary(instruction, form, FloatingBinary_MAX);
        when ScalarOperation_FEQ => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_EQ, FALSE);
        when ScalarOperation_FEQS => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_EQ, TRUE);
        when ScalarOperation_FNE => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_NE, FALSE);
        when ScalarOperation_FNES => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_NE, TRUE);
        when ScalarOperation_FLT => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_LT, FALSE);
        when ScalarOperation_FLTS => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_LT, TRUE);
        when ScalarOperation_FGE => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_GE, FALSE);
        when ScalarOperation_FGES => ExecuteDecodedFPCompare(
            instruction, form, FloatingCompare_GE, TRUE);
        when ScalarOperation_FMADD => ExecuteDecodedFPFused(
            instruction, form, FloatingFused_MADD);
        when ScalarOperation_FMSUB => ExecuteDecodedFPFused(
            instruction, form, FloatingFused_MSUB);
        when ScalarOperation_FNMADD => ExecuteDecodedFPFused(
            instruction, form, FloatingFused_NMADD);
        when ScalarOperation_FNMSUB => ExecuteDecodedFPFused(
            instruction, form, FloatingFused_NMSUB);
        when ScalarOperation_FCVT, ScalarOperation_FCVTA,
             ScalarOperation_FCVTM, ScalarOperation_FCVTN,
             ScalarOperation_FCVTP, ScalarOperation_FCVTZ,
             ScalarOperation_SCVTF, ScalarOperation_UCVTF =>
            ExecuteDecodedFPConvert(instruction, form, operation);
        otherwise => unreachable;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
