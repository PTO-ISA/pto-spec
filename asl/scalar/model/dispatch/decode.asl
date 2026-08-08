// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-DECODE","surface":"scalar","classification":["model","dispatch","decode"],"depends_on":["generated:decoders","PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// PTO-REQ-SCALAR-DISPATCH-001, PTO-REQ-SCALAR-CONSTRAINT-001: decoded scalar
// execution with catalog-generated form and family legality.
//
// Every accepted scalar family has a form-to-effect binding. Unknown or
// operand-illegal encodings are rejected; there is no silent unsupported path.

type ScalarExecutionStatus of enumeration {
    ScalarExecution_Executed,
    ScalarExecution_Rejected
};

pure func ScalarHandlerWritesTPC(handler: ScalarSemanticHandler) => boolean
begin
    return handler == ScalarHandler_BranchRelative ||
           handler == ScalarHandler_JumpRelative ||
           handler == ScalarHandler_JumpRegister ||
           handler == ScalarHandler_ArchitectureEnterRequest;
end;

pure func ScalarDecodedSelector(instruction: bits(48),
                                form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                field: ScalarOperandField) => Reg5Selector
begin
    let raw = DecodeScalarOperandRaw(instruction, form, field);
    return UInt(raw[4:0]) as Reg5Selector;
end;

pure func ScalarDecodedWord(instruction: bits(48),
                            form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                            field: ScalarOperandField) => Word
begin
    let raw = DecodeScalarOperandRaw(instruction, form, field);
    if ScalarOperandSignedness(form, field) == ScalarField_Signed then
        case ScalarOperandWidth(form, field) of
            when 5  => return SignExtend{PTO_XLEN}(raw[4:0]);
            when 12 => return SignExtend{PTO_XLEN}(raw[11:0]);
            when 17 => return SignExtend{PTO_XLEN}(raw[16:0]);
            when 22 => return SignExtend{PTO_XLEN}(raw[21:0]);
            when 24 => return SignExtend{PTO_XLEN}(raw[23:0]);
            when 29 => return SignExtend{PTO_XLEN}(raw[28:0]);
            when 32 => return SignExtend{PTO_XLEN}(raw[31:0]);
            otherwise => unreachable;
        end;
    end;
    return ZeroExtend{PTO_XLEN}(raw);
end;

pure func ScalarDecodedBits19(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(19)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[18:0];
end;

pure func ScalarDecodedBits20(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(20)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[19:0];
end;

pure func ScalarDecodedBits4(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => bits(4)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[3:0];
end;

pure func ScalarDecodedBits5(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => bits(5)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[4:0];
end;

pure func ScalarDecodedSystemRegisterAddress(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    field: ScalarOperandField) => SystemRegisterAddress
begin
    return DecodeScalarOperandRaw(instruction, form, field)[23:0];
end;

pure func ScalarDecodedBoolean(instruction: bits(48),
                               form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                               field: ScalarOperandField) => boolean
begin
    return DecodeScalarOperandRaw(instruction, form, field)[0] == '1';
end;

pure func ScalarDecodedMemoryOrder(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1})
    => MemoryOrder
begin
    let acquire = ScalarDecodedBoolean(instruction, form, ScalarField_aq);
    let release = ScalarDecodedBoolean(instruction, form, ScalarField_rl);
    if acquire && release then return MemoryOrder_AcquireRelease;
    elsif acquire then return MemoryOrder_Acquire;
    elsif release then return MemoryOrder_Release;
    else return MemoryOrder_Relaxed;
    end;
end;

readonly func ScalarDecodedAtomicAddress(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    field: ScalarOperandField) => Word
begin
    let address = ReadDecodedScalarRegister(instruction, form, field);
    let far = ScalarDecodedBoolean(instruction, form, ScalarField_far);
    return AtomicAddress(address, far);
end;

pure func ScalarDecodedBits32(instruction: bits(48),
                              form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                              field: ScalarOperandField) => bits(32)
begin
    return DecodeScalarOperandRaw(instruction, form, field)[31:0];
end;

pure func ScalarDecodedUInt6(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => integer {0..63}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, field)[5:0]);
end;

pure func ScalarDecodedUInt7(instruction: bits(48),
                             form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                             field: ScalarOperandField) => integer {0..127}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, field)[6:0]);
end;

pure func ScalarDecodedBitfieldWidth(instruction: bits(48),
                                     form: integer {0..PTO_SCALAR_FORM_COUNT-1})
                                     => integer {1..64}
begin
    return UInt(DecodeScalarOperandRaw(instruction, form, ScalarField_imml)[5:0]) + 1;
end;

pure func ScalarDecodedRightModifier(instruction: bits(48),
                                     form: integer {0..PTO_SCALAR_FORM_COUNT-1})
                                     => ScalarRightModifier
begin
    let raw = DecodeScalarOperandRaw(instruction, form, ScalarField_SrcRType)[1:0];
    case raw of
        when '00' => return ScalarRight_None;
        when '01' => return ScalarRight_SignedWord;
        when '10' => return ScalarRight_UnsignedWord;
        when '11' => return ScalarRight_NegateOrNot;
    end;
end;

readonly func ReadDecodedScalarRegister(instruction: bits(48),
                                        form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                        field: ScalarOperandField) => Word
begin
    return ReadScalarRegisterOperand(ScalarDecodedSelector(instruction, form, field));
end;

