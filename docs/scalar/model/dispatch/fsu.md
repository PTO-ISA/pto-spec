<!-- GENERATED FROM: asl/scalar/model/dispatch/fsu.asl -->
# FSU

**Normative ASL source:** `asl/scalar/model/dispatch/fsu.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-FSU}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/fsu.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-FSU","surface":"scalar","classification":["model","dispatch","fsu"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-FSU-PROFILE","PTO-SCALAR-FABS","PTO-SCALAR-FADD","PTO-SCALAR-FCVT","PTO-SCALAR-FCVTA","PTO-SCALAR-FCVTM","PTO-SCALAR-FCVTN","PTO-SCALAR-FCVTP","PTO-SCALAR-FCVTZ","PTO-SCALAR-FDIV","PTO-SCALAR-FEQ","PTO-SCALAR-FEQS","PTO-SCALAR-FEXP","PTO-SCALAR-FGE","PTO-SCALAR-FGES","PTO-SCALAR-FLT","PTO-SCALAR-FLTS","PTO-SCALAR-FMADD","PTO-SCALAR-FMAX","PTO-SCALAR-FMIN","PTO-SCALAR-FMSUB","PTO-SCALAR-FMUL","PTO-SCALAR-FNE","PTO-SCALAR-FNES","PTO-SCALAR-FNMADD","PTO-SCALAR-FNMSUB","PTO-SCALAR-FRECIP","PTO-SCALAR-FSQRT","PTO-SCALAR-FSUB","PTO-SCALAR-SCVTF","PTO-SCALAR-UCVTF"]}
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
        source_supported = ScalarIntegerTypeCodeSupported(source_type);
        destination_supported = ScalarFPTypeCodeSupported(destination_type);
    elsif operation == ScalarOperation_UCVTF then
        source_type = ScalarUnsignedIntegerSourceTypeCode(source_selector);
        destination_type = raw_destination_type;
        source_supported = ScalarIntegerTypeCodeSupported(source_type);
        destination_supported = ScalarFPTypeCodeSupported(destination_type);
    else
        source_type = ScalarFPSourceTypeCode(source_selector);
        source_supported = ScalarFPTypeCodeSupported(source_type);
        if operation == ScalarOperation_FCVT then
            destination_type = raw_destination_type;
            destination_supported = ScalarFPTypeCodeSupported(destination_type);
        else
            destination_type = ScalarFPToIntegerDestinationTypeCode(
                raw_destination_type);
            destination_supported = ScalarIntegerTypeCodeSupported(destination_type);
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
            NormalizeScalarFPSource(value, source_type));
        result = NormalizeScalarFPResult(result, destination_type);
    elsif operation == ScalarOperation_SCVTF ||
          operation == ScalarOperation_UCVTF then
        (result, flags) = ScalarIntegerToFPProfile(
            ScalarFPActiveRoundingMode(), source_type, destination_type,
            NormalizeScalarIntegerSource(value, source_type));
        result = NormalizeScalarFPResult(result, destination_type);
    else
        let rounding_mode = ScalarFPFixedConversionRoundingMode(operation);
        (result, flags) = ScalarFPToIntegerProfile(
            rounding_mode, destination_type, source_type,
            NormalizeScalarFPSource(value, source_type));
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
