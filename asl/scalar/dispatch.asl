// PTO-REQ-SCALAR-DISPATCH-001: decoded scalar execution and rejection contract.
//
// The public entry point deliberately reports recognized families that do not
// yet have form-to-effect bindings. A recognized but unsupported form does not
// mutate architectural state and is distinct from an illegal encoding.

type ScalarExecutionStatus of enumeration {
    ScalarExecution_Executed,
    ScalarExecution_Unsupported,
    ScalarExecution_Rejected
};

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

func ExecuteDecodedBinary(instruction: bits(48),
                          form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                          operation: ScalarBinaryOperation,
                          logical_family: boolean, word_operation: boolean)
begin
    let destination = ScalarDecodedSelector(instruction, form, ScalarField_RegDst);
    let left = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL);
    let unmodified_right = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR);
    let modifier = ScalarDecodedRightModifier(instruction, form);
    let shift_amount = ScalarDecodedUInt6(instruction, form, ScalarField_shamt);
    let right = PrepareScalarRight(unmodified_right, modifier, shift_amount, logical_family);
    let result = if word_operation then ScalarBinaryW(operation, left, right)
                 else ScalarBinary(operation, left, right);
    WriteScalarDestination(destination, result);
end;

func ExecuteDecodedImmediateBinary(instruction: bits(48),
                                   form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                   operation: ScalarBinaryOperation,
                                   immediate_field: ScalarOperandField,
                                   word_operation: boolean)
begin
    let destination = ScalarDecodedSelector(instruction, form, ScalarField_RegDst);
    let left = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL);
    let right = ScalarDecodedWord(instruction, form, immediate_field);
    let result = if word_operation then ScalarBinaryW(operation, left, right)
                 else ScalarBinary(operation, left, right);
    WriteScalarDestination(destination, result);
end;

func ExecuteDecodedSimpleBinary(instruction: bits(48),
                                form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                operation: ScalarBinaryOperation,
                                word_operation: boolean)
begin
    let destination = ScalarDecodedSelector(instruction, form, ScalarField_RegDst);
    let left = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL);
    let right = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR);
    let result = if word_operation then ScalarBinaryW(operation, left, right)
                 else ScalarBinary(operation, left, right);
    WriteScalarDestination(destination, result);
end;

func ExecuteDecodedShiftImmediate(instruction: bits(48),
                                  form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                  operation: ScalarBinaryOperation,
                                  word_operation: boolean)
begin
    let destination = ScalarDecodedSelector(instruction, form, ScalarField_RegDst);
    let left = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL);
    let amount = ScalarDecodedWord(instruction, form, ScalarField_shamt);
    let result = if word_operation then ScalarBinaryW(operation, left, amount)
                 else ScalarBinary(operation, left, amount);
    WriteScalarDestination(destination, result);
end;

func ExecuteDecodedCompressedBinary(instruction: bits(48),
                                    form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                    operation: ScalarBinaryOperation)
begin
    let left = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL);
    let right = ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR);
    WriteCompressedTResult(ScalarBinary(operation, left, right));
end;

func ExecuteDecodedALUForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_ADD =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_ADD, FALSE, FALSE);
        when ScalarOperation_ADDW =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_ADD, FALSE, TRUE);
        when ScalarOperation_AND =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_AND, TRUE, FALSE);
        when ScalarOperation_ANDW =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_AND, TRUE, TRUE);
        when ScalarOperation_OR =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_OR, TRUE, FALSE);
        when ScalarOperation_ORW =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_OR, TRUE, TRUE);
        when ScalarOperation_SUB =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_SUB, FALSE, FALSE);
        when ScalarOperation_SUBW =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_SUB, FALSE, TRUE);
        when ScalarOperation_XOR =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_XOR, TRUE, FALSE);
        when ScalarOperation_XORW =>
            ExecuteDecodedBinary(instruction, form, ScalarBinary_XOR, TRUE, TRUE);

        when ScalarOperation_ADDI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_ADD,
                ScalarField_uimm12, FALSE);
        when ScalarOperation_ADDIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_ADD,
                ScalarField_uimm12, TRUE);
        when ScalarOperation_ANDI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_AND,
                ScalarField_simm12, FALSE);
        when ScalarOperation_ANDIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_AND,
                ScalarField_simm12, TRUE);
        when ScalarOperation_ORI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_OR,
                ScalarField_simm12, FALSE);
        when ScalarOperation_ORIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_OR,
                ScalarField_simm12, TRUE);
        when ScalarOperation_SUBI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_SUB,
                ScalarField_uimm12, FALSE);
        when ScalarOperation_SUBIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_SUB,
                ScalarField_uimm12, TRUE);
        when ScalarOperation_XORI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_XOR,
                ScalarField_simm12, FALSE);
        when ScalarOperation_XORIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_XOR,
                ScalarField_simm12, TRUE);

        when ScalarOperation_HL_ADDI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_ADD,
                ScalarField_uimm24, FALSE);
        when ScalarOperation_HL_ADDIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_ADD,
                ScalarField_uimm24, TRUE);
        when ScalarOperation_HL_ANDI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_AND,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_ANDIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_AND,
                ScalarField_simm24, TRUE);
        when ScalarOperation_HL_ORI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_OR,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_ORIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_OR,
                ScalarField_simm24, TRUE);
        when ScalarOperation_HL_SUBI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_SUB,
                ScalarField_uimm24, FALSE);
        when ScalarOperation_HL_SUBIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_SUB,
                ScalarField_uimm24, TRUE);
        when ScalarOperation_HL_XORI =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_XOR,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_XORIW =>
            ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_XOR,
                ScalarField_simm24, TRUE);

        when ScalarOperation_C_ADD =>
            ExecuteDecodedCompressedBinary(instruction, form, ScalarBinary_ADD);
        when ScalarOperation_C_AND =>
            ExecuteDecodedCompressedBinary(instruction, form, ScalarBinary_AND);
        when ScalarOperation_C_OR =>
            ExecuteDecodedCompressedBinary(instruction, form, ScalarBinary_OR);
        when ScalarOperation_C_SUB =>
            ExecuteDecodedCompressedBinary(instruction, form, ScalarBinary_SUB);
        when ScalarOperation_C_ADDI =>
            WriteCompressedTResult(ScalarBinary(ScalarBinary_ADD,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ScalarDecodedWord(instruction, form, ScalarField_simm5)));
        when ScalarOperation_C_SLLI =>
            WriteCompressedTResult(ScalarBinary(ScalarBinary_SLL,
                ReadScalarRegisterOperand(24),
                ScalarDecodedWord(instruction, form, ScalarField_uimm5)));
        when ScalarOperation_C_SRLI =>
            WriteCompressedTResult(ScalarBinary(ScalarBinary_SRL,
                ReadScalarRegisterOperand(24),
                ScalarDecodedWord(instruction, form, ScalarField_uimm5)));

        when ScalarOperation_SLL =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_SLL, FALSE);
        when ScalarOperation_SLLW =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_SLL, TRUE);
        when ScalarOperation_SRL =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_SRL, FALSE);
        when ScalarOperation_SRLW =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_SRL, TRUE);
        when ScalarOperation_SRA =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_SRA, FALSE);
        when ScalarOperation_SRAW =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_SRA, TRUE);
        when ScalarOperation_SLLI =>
            ExecuteDecodedShiftImmediate(instruction, form, ScalarBinary_SLL, FALSE);
        when ScalarOperation_SLLIW =>
            ExecuteDecodedShiftImmediate(instruction, form, ScalarBinary_SLL, TRUE);
        when ScalarOperation_SRLI =>
            ExecuteDecodedShiftImmediate(instruction, form, ScalarBinary_SRL, FALSE);
        when ScalarOperation_SRLIW =>
            ExecuteDecodedShiftImmediate(instruction, form, ScalarBinary_SRL, TRUE);
        when ScalarOperation_SRAI =>
            ExecuteDecodedShiftImmediate(instruction, form, ScalarBinary_SRA, FALSE);
        when ScalarOperation_SRAIW =>
            ExecuteDecodedShiftImmediate(instruction, form, ScalarBinary_SRA, TRUE);

        when ScalarOperation_MAX =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MAX, FALSE);
        when ScalarOperation_MAXU =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MAXU, FALSE);
        when ScalarOperation_MIN =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MIN, FALSE);
        when ScalarOperation_MINU =>
            ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MINU, FALSE);

        when ScalarOperation_DIV =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDivideSigned(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_DIVU =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDivideUnsigned(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_DIVW =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDivideSignedW(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_DIVUW =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDivideUnsignedW(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_REM =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarRemainderSigned(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_REMU =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarRemainderUnsigned(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_REMW =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarRemainderSignedW(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_REMUW =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarRemainderUnsignedW(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));

        when ScalarOperation_MUL, ScalarOperation_MULU =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                MultiplyWord(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_MULW, ScalarOperation_MULUW =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarMultiplyW(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_MADD =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarMultiplyAdd(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));
        when ScalarOperation_MADDW =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarMultiplyAddW(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR)));

        when ScalarOperation_HL_MUL =>
            ExecuteScalarMultiplyPair(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR), TRUE);
        when ScalarOperation_HL_MULU =>
            ExecuteScalarMultiplyPair(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR), FALSE);
        when ScalarOperation_HL_MADD, ScalarOperation_HL_MADDW =>
            ExecuteScalarMultiplyAddPair(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                operation == ScalarOperation_HL_MADDW);

        when ScalarOperation_HL_DIV, ScalarOperation_HL_REM,
             ScalarOperation_HL_DIVU, ScalarOperation_HL_REMU =>
            ExecuteScalarDividePair(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                operation == ScalarOperation_HL_DIV || operation == ScalarOperation_HL_REM);
        when ScalarOperation_HL_DIVW, ScalarOperation_HL_REMW,
             ScalarOperation_HL_DIVUW, ScalarOperation_HL_REMUW =>
            ExecuteScalarDividePairW(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                operation == ScalarOperation_HL_DIVW || operation == ScalarOperation_HL_REMW);

        when ScalarOperation_HL_CCAT =>
            ExecuteConcatenatePair(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                ScalarDecodedUInt7(instruction, form, ScalarField_shamt));
        when ScalarOperation_HL_CCATW =>
            ExecuteConcatenatePairW(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst0),
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst1),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                ScalarDecodedUInt7(instruction, form, ScalarField_shamt));

        when ScalarOperation_HL_MIADD, ScalarOperation_HL_MISUB =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarMultiplyImmediateAdd(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                    ScalarDecodedBits19(instruction, form, ScalarField_uimm19),
                    operation == ScalarOperation_HL_MISUB));

        when ScalarOperation_BXS, ScalarOperation_BXU =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ExtractBitfield(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ScalarDecodedBitfieldWidth(instruction, form),
                    ScalarDecodedUInt6(instruction, form, ScalarField_imms),
                    operation == ScalarOperation_BXS));
        when ScalarOperation_CLZ, ScalarOperation_CTZ, ScalarOperation_BCNT =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                CountBitfield(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ScalarDecodedBitfieldWidth(instruction, form),
                    ScalarDecodedUInt6(instruction, form, ScalarField_imms),
                    operation == ScalarOperation_CLZ,
                    operation == ScalarOperation_BCNT));
        when ScalarOperation_BIC, ScalarOperation_BIS =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ModifyBitfield(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ScalarDecodedBitfieldWidth(instruction, form),
                    ScalarDecodedUInt6(instruction, form, ScalarField_imms),
                    operation == ScalarOperation_BIS));
        when ScalarOperation_REV =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ReverseBitfieldBytes(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ScalarDecodedBitfieldWidth(instruction, form),
                    ScalarDecodedUInt6(instruction, form, ScalarField_immr)));
        when ScalarOperation_HL_BFI =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                InsertBitfield(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                    ScalarDecodedUInt6(instruction, form, ScalarField_immr),
                    ScalarDecodedUInt6(instruction, form, ScalarField_imms)));

        when ScalarOperation_CSEL =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarConditionalSelect(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcP),
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                    ApplySelectModifier(
                        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                        ScalarDecodedRightModifier(instruction, form))));

        when ScalarOperation_LUI =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                MaterializeLUI(ScalarDecodedBits20(instruction, form, ScalarField_imm20)));
        when ScalarOperation_HL_LUI =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                MaterializeLongSigned(ScalarDecodedBits32(instruction, form, ScalarField_imm)));
        when ScalarOperation_HL_LIS =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                MaterializeLongSigned(ScalarDecodedBits32(instruction, form, ScalarField_simm32)));
        when ScalarOperation_HL_LIU =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                MaterializeLongUnsigned(ScalarDecodedBits32(instruction, form, ScalarField_uimm32)));
        when ScalarOperation_C_MOVI =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedWord(instruction, form, ScalarField_simm5));
        when ScalarOperation_C_MOVR =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));

        when ScalarOperation_C_SEXT_B, ScalarOperation_C_ZEXT_B =>
            WriteCompressedTResult(ExtendScalarValue(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), 8,
                operation == ScalarOperation_C_SEXT_B));
        when ScalarOperation_C_SEXT_H, ScalarOperation_C_ZEXT_H =>
            WriteCompressedTResult(ExtendScalarValue(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), 16,
                operation == ScalarOperation_C_SEXT_H));
        when ScalarOperation_C_SEXT_W, ScalarOperation_C_ZEXT_W =>
            WriteCompressedTResult(ExtendScalarValue(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), 32,
                operation == ScalarOperation_C_SEXT_W));
        when ScalarOperation_C_SETC_TGT =>
            SetCommitTarget(ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_C_SETRET =>
            SetReturnAddress(ScalarDecodedWord(instruction, form, ScalarField_uimm5));

        otherwise => unreachable;
    end;
end;

pure func ScalarConditionForOperation(operation: ScalarOperation) => ScalarCondition
begin
    case operation of
        when ScalarOperation_B_EQ, ScalarOperation_C_CMP_EQI,
             ScalarOperation_C_SETC_EQ, ScalarOperation_CMP_EQ,
             ScalarOperation_CMP_EQI, ScalarOperation_HL_CMP_EQI,
             ScalarOperation_HL_SETC_EQI, ScalarOperation_SETC_EQ,
             ScalarOperation_SETC_EQI => return ScalarCondition_EQ;
        when ScalarOperation_B_NE, ScalarOperation_C_CMP_NEI,
             ScalarOperation_C_SETC_NE, ScalarOperation_CMP_NE,
             ScalarOperation_CMP_NEI, ScalarOperation_HL_CMP_NEI,
             ScalarOperation_HL_SETC_NEI, ScalarOperation_SETC_NE,
             ScalarOperation_SETC_NEI => return ScalarCondition_NE;
        when ScalarOperation_B_LT, ScalarOperation_CMP_LT,
             ScalarOperation_CMP_LTI, ScalarOperation_HL_CMP_LTI,
             ScalarOperation_HL_SETC_LTI, ScalarOperation_SETC_LT,
             ScalarOperation_SETC_LTI => return ScalarCondition_LT;
        when ScalarOperation_B_GE, ScalarOperation_CMP_GE,
             ScalarOperation_CMP_GEI, ScalarOperation_HL_CMP_GEI,
             ScalarOperation_HL_SETC_GEI, ScalarOperation_SETC_GE,
             ScalarOperation_SETC_GEI => return ScalarCondition_GE;
        when ScalarOperation_B_LTU, ScalarOperation_CMP_LTU,
             ScalarOperation_CMP_LTUI, ScalarOperation_HL_CMP_LTUI,
             ScalarOperation_HL_SETC_LTUI, ScalarOperation_SETC_LTU,
             ScalarOperation_SETC_LTUI => return ScalarCondition_LTU;
        when ScalarOperation_B_GEU, ScalarOperation_CMP_GEU,
             ScalarOperation_CMP_GEUI, ScalarOperation_HL_CMP_GEUI,
             ScalarOperation_HL_SETC_GEUI, ScalarOperation_SETC_GEU,
             ScalarOperation_SETC_GEUI => return ScalarCondition_GEU;
        when ScalarOperation_B_Z => return ScalarCondition_Z;
        when ScalarOperation_B_NZ => return ScalarCondition_NZ;
        otherwise => unreachable;
    end;
end;

func ExecuteDecodedCompareRegister(instruction: bits(48),
                                   form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                   operation: ScalarOperation)
begin
    let right = ApplyRestrictedCompareModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedRightModifier(instruction, form));
    ExecuteCompare(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), right);
end;

func ExecuteDecodedCompareImmediate(instruction: bits(48),
                                    form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                    operation: ScalarOperation,
                                    immediate_field: ScalarOperandField)
begin
    ExecuteCompare(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedWord(instruction, form, immediate_field));
end;

func ExecuteDecodedCompareLogicalRegister(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    combine_or: boolean)
begin
    let right = ApplyScalarRightModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedRightModifier(instruction, form), TRUE);
    ExecuteCompareLogical(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        right, combine_or);
end;

func ExecuteDecodedCompareLogicalImmediate(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    immediate_field: ScalarOperandField, combine_or: boolean)
begin
    ExecuteCompareLogical(
        ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedWord(instruction, form, immediate_field), combine_or);
end;

func ExecuteDecodedSetCommitRegister(instruction: bits(48),
                                     form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                     operation: ScalarOperation)
begin
    let right = ApplyRestrictedCompareModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedRightModifier(instruction, form));
    ExecuteSetCommit(ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL), right);
end;

func ExecuteDecodedSetCommitImmediate(instruction: bits(48),
                                      form: integer {0..PTO_SCALAR_FORM_COUNT-1},
                                      operation: ScalarOperation,
                                      immediate_field: ScalarOperandField)
begin
    let shifted_immediate = LSL(
        ScalarDecodedWord(instruction, form, immediate_field),
        ScalarDecodedUInt6(instruction, form, ScalarField_shamt));
    ExecuteSetCommit(ScalarConditionForOperation(operation),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        shifted_immediate);
end;

func ExecuteDecodedSetCommitLogicalRegister(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    combine_or: boolean)
begin
    let right = ApplyScalarRightModifier(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedRightModifier(instruction, form), TRUE);
    ExecuteSetCommitLogical(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        right, combine_or);
end;

func ExecuteDecodedSetCommitLogicalImmediate(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    immediate_field: ScalarOperandField, combine_or: boolean)
begin
    let shifted_immediate = LSL(
        ScalarDecodedWord(instruction, form, immediate_field),
        ScalarDecodedUInt6(instruction, form, ScalarField_shamt));
    ExecuteSetCommitLogical(
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        shifted_immediate, combine_or);
end;

func ExecuteDecodedBRUForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_CMP_EQ, ScalarOperation_CMP_NE,
             ScalarOperation_CMP_LT, ScalarOperation_CMP_GE,
             ScalarOperation_CMP_LTU, ScalarOperation_CMP_GEU =>
            ExecuteDecodedCompareRegister(instruction, form, operation);
        when ScalarOperation_CMP_EQI, ScalarOperation_CMP_NEI,
             ScalarOperation_CMP_LTI, ScalarOperation_CMP_GEI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_simm12);
        when ScalarOperation_CMP_LTUI, ScalarOperation_CMP_GEUI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_uimm12);
        when ScalarOperation_HL_CMP_EQI, ScalarOperation_HL_CMP_NEI,
             ScalarOperation_HL_CMP_LTI, ScalarOperation_HL_CMP_GEI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_simm24);
        when ScalarOperation_HL_CMP_LTUI, ScalarOperation_HL_CMP_GEUI =>
            ExecuteDecodedCompareImmediate(instruction, form, operation,
                ScalarField_uimm24);
        when ScalarOperation_CMP_AND =>
            ExecuteDecodedCompareLogicalRegister(instruction, form, FALSE);
        when ScalarOperation_CMP_OR =>
            ExecuteDecodedCompareLogicalRegister(instruction, form, TRUE);
        when ScalarOperation_CMP_ANDI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm12, FALSE);
        when ScalarOperation_CMP_ORI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm12, TRUE);
        when ScalarOperation_HL_CMP_ANDI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_CMP_ORI =>
            ExecuteDecodedCompareLogicalImmediate(instruction, form,
                ScalarField_simm24, TRUE);

        when ScalarOperation_C_CMP_EQI, ScalarOperation_C_CMP_NEI =>
            ExecuteCompare(31, ScalarConditionForOperation(operation),
                ReadScalarRegisterOperand(24),
                ScalarDecodedWord(instruction, form, ScalarField_simm5));

        when ScalarOperation_SETC_EQ, ScalarOperation_SETC_NE,
             ScalarOperation_SETC_LT, ScalarOperation_SETC_GE,
             ScalarOperation_SETC_LTU, ScalarOperation_SETC_GEU =>
            ExecuteDecodedSetCommitRegister(instruction, form, operation);
        when ScalarOperation_SETC_EQI, ScalarOperation_SETC_NEI,
             ScalarOperation_SETC_LTI, ScalarOperation_SETC_GEI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_simm12);
        when ScalarOperation_SETC_LTUI, ScalarOperation_SETC_GEUI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_uimm12);
        when ScalarOperation_HL_SETC_EQI, ScalarOperation_HL_SETC_NEI,
             ScalarOperation_HL_SETC_LTI, ScalarOperation_HL_SETC_GEI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_simm24);
        when ScalarOperation_HL_SETC_LTUI, ScalarOperation_HL_SETC_GEUI =>
            ExecuteDecodedSetCommitImmediate(instruction, form, operation,
                ScalarField_uimm24);
        when ScalarOperation_SETC_AND =>
            ExecuteDecodedSetCommitLogicalRegister(instruction, form, FALSE);
        when ScalarOperation_SETC_OR =>
            ExecuteDecodedSetCommitLogicalRegister(instruction, form, TRUE);
        when ScalarOperation_SETC_ANDI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm12, FALSE);
        when ScalarOperation_SETC_ORI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm12, TRUE);
        when ScalarOperation_HL_SETC_ANDI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm24, FALSE);
        when ScalarOperation_HL_SETC_ORI =>
            ExecuteDecodedSetCommitLogicalImmediate(instruction, form,
                ScalarField_simm24, TRUE);
        when ScalarOperation_C_SETC_EQ, ScalarOperation_C_SETC_NE =>
            ExecuteSetCommit(ScalarConditionForOperation(operation),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR));

        when ScalarOperation_B_EQ, ScalarOperation_B_NE,
             ScalarOperation_B_LT, ScalarOperation_B_GE,
             ScalarOperation_B_LTU, ScalarOperation_B_GEU =>
            BranchRelative(ScalarConditionForOperation(operation),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
                ScalarDecodedWord(instruction, form, ScalarField_simm12));
        when ScalarOperation_B_Z, ScalarOperation_B_NZ =>
            BranchRelative(ScalarConditionForOperation(operation),
                ReadPredicateMask(), Zeros{PTO_XLEN},
                ScalarDecodedWord(instruction, form, ScalarField_simm22));
        when ScalarOperation_J =>
            JumpRelative(ScalarDecodedWord(instruction, form, ScalarField_simm22));
        when ScalarOperation_JR =>
            JumpRegister(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL) +
                LSL(ScalarDecodedWord(instruction, form, ScalarField_simm12), 1));

        when ScalarOperation_ADDTPC =>
            AddToPC(ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                SignExtend{PTO_XLEN}(
                    ScalarDecodedBits20(instruction, form, ScalarField_imm20)));
        when ScalarOperation_HL_ADDTPC =>
            AddToPC(ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                SignExtend{PTO_XLEN}(
                    ScalarDecodedBits32(instruction, form, ScalarField_imm32)));
        when ScalarOperation_SETRET =>
            SetReturnAddress(ZeroExtend{PTO_XLEN}(
                ScalarDecodedBits20(instruction, form, ScalarField_imm20)));
        when ScalarOperation_HL_SETRET =>
            SetReturnAddress(ZeroExtend{PTO_XLEN}(
                ScalarDecodedBits32(instruction, form, ScalarField_imm32)));
        otherwise => unreachable;
    end;
end;

func ExecuteDecodedSYSForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_ACRC =>
            ArchitectureCloseRequest(ScalarDecodedBits4(
                instruction, form, ScalarField_RST_Type));
        when ScalarOperation_ACRE =>
            ArchitectureEnterRequest(ScalarDecodedBits4(
                instruction, form, ScalarField_RRA_Type));
        when ScalarOperation_ASSERT =>
            ArchitectureAssert(ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));

        when ScalarOperation_BC_IALL =>
            ExecuteMaintenance(Maintenance_BC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_BC_IVA =>
            ExecuteMaintenance(Maintenance_BC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_IALL =>
            ExecuteMaintenance(Maintenance_DC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_DC_IVA =>
            ExecuteMaintenance(Maintenance_DC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_ISW =>
            ExecuteMaintenance(Maintenance_DC_ISW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_ZVA =>
            ExecuteMaintenance(Maintenance_DC_ZVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CVA =>
            ExecuteMaintenance(Maintenance_DC_CVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CIVA =>
            ExecuteMaintenance(Maintenance_DC_CIVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CSW =>
            ExecuteMaintenance(Maintenance_DC_CSW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_DC_CISW =>
            ExecuteMaintenance(Maintenance_DC_CISW, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_IC_IALL =>
            ExecuteMaintenance(Maintenance_IC_IALL, Zeros{PTO_XLEN});
        when ScalarOperation_IC_IVA =>
            ExecuteMaintenance(Maintenance_IC_IVA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IV =>
            ExecuteMaintenance(Maintenance_TLB_IV, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IAV =>
            ExecuteMaintenance(Maintenance_TLB_IAV, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IA =>
            ExecuteMaintenance(Maintenance_TLB_IA, ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        when ScalarOperation_TLB_IALL =>
            ExecuteMaintenance(Maintenance_TLB_IALL, Zeros{PTO_XLEN});

        when ScalarOperation_BSE =>
            ExecuteControlRequest(ExecutionControl_SendEvent,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWE =>
            ExecuteControlRequest(ExecutionControl_WaitEvent,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWI =>
            ExecuteControlRequest(ExecutionControl_WaitInterrupt,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));
        when ScalarOperation_BWT =>
            ExecuteControlRequest(ExecutionControl_WaitTimeout,
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL));

        when ScalarOperation_C_EBREAK =>
            SoftwareBreakpoint(ScalarDecodedBits5(
                instruction, form, ScalarField_imm5));
        when ScalarOperation_EBREAK =>
            SoftwareBreakpoint(ZeroExtend{5}(ScalarDecodedBits4(
                instruction, form, ScalarField_imm4)));
        when ScalarOperation_FENCE_D =>
            FenceData(
                ScalarDecodedBits4(instruction, form, ScalarField_PRED_IMM),
                ScalarDecodedBits4(instruction, form, ScalarField_SUCC_IMM));
        when ScalarOperation_FENCE_I => FenceInstruction();

        when ScalarOperation_C_SSRGET =>
            ExecuteCompressedSystemRegisterGet(
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSRID));
        when ScalarOperation_HL_SSRGET =>
            ExecuteSystemRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_HL_SSRSET =>
            ExecuteSystemRegisterSet(
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_LSRGET =>
            ExecuteSystemRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_LSR_ID));
        when ScalarOperation_SSRGET =>
            ExecuteSystemRegisterGet(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SSRSET =>
            ExecuteSystemRegisterSet(
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SSRSWAP =>
            ExecuteSystemRegisterSwap(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                ScalarDecodedSelector(instruction, form, ScalarField_SrcL),
                ScalarDecodedSystemRegisterAddress(
                    instruction, form, ScalarField_SSR_ID));
        when ScalarOperation_SETC_TGT =>
            SetCommitTarget(ReadDecodedScalarRegister(
                instruction, form, ScalarField_SrcL));
        otherwise => unreachable;
    end;
end;

pure func ScalarAtomicOperationForOperation(operation: ScalarOperation)
        => AtomicOperation
begin
    case operation of
        when ScalarOperation_LD_ADD, ScalarOperation_LW_ADD,
             ScalarOperation_SD_ADD, ScalarOperation_SW_ADD =>
            return Atomic_ADD;
        when ScalarOperation_LD_AND, ScalarOperation_LW_AND,
             ScalarOperation_SD_AND, ScalarOperation_SW_AND =>
            return Atomic_AND;
        when ScalarOperation_LD_OR, ScalarOperation_LW_OR,
             ScalarOperation_SD_OR, ScalarOperation_SW_OR =>
            return Atomic_OR;
        when ScalarOperation_LD_XOR, ScalarOperation_LW_XOR,
             ScalarOperation_SD_XOR, ScalarOperation_SW_XOR =>
            return Atomic_XOR;
        when ScalarOperation_LD_SMIN, ScalarOperation_LW_SMIN,
             ScalarOperation_SD_SMIN, ScalarOperation_SW_SMIN =>
            return Atomic_SMIN;
        when ScalarOperation_LD_SMAX, ScalarOperation_LW_SMAX,
             ScalarOperation_SD_SMAX, ScalarOperation_SW_SMAX =>
            return Atomic_SMAX;
        when ScalarOperation_LD_UMIN, ScalarOperation_LW_UMIN,
             ScalarOperation_SD_UMIN, ScalarOperation_SW_UMIN =>
            return Atomic_UMIN;
        when ScalarOperation_LD_UMAX, ScalarOperation_LW_UMAX,
             ScalarOperation_SD_UMAX, ScalarOperation_SW_UMAX =>
            return Atomic_UMAX;
        otherwise => unreachable;
    end;
end;

func ExecuteDecodedLoadReserved(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let old_value = LoadReserved(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes, ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedStoreConditional(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let status = StoreConditional(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcR),
        size_bytes,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
        ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst), status);
    end;
end;

func ExecuteDecodedAtomicReadModifyWrite(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    operation: AtomicOperation, size_bytes: integer {1,2,4,8},
    write_result: boolean)
begin
    let old_value = AtomicReadModifyWrite(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes, operation,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ScalarDecodedMemoryOrder(instruction, form));
    if write_result && _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedCompareAndSwap(
    instruction: bits(48), form: integer {0..PTO_SCALAR_FORM_COUNT-1},
    size_bytes: integer {1,2,4,8})
begin
    let old_value = CompareAndSwap(
        ScalarDecodedAtomicAddress(instruction, form, ScalarField_SrcL),
        size_bytes,
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR),
        ReadDecodedScalarRegister(instruction, form, ScalarField_SrcD),
        ScalarDecodedMemoryOrder(instruction, form));
    if _LastFault == Fault_None then
        WriteScalarDestination(
            ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
            NormalizeAtomicReturn(old_value, size_bytes));
    end;
end;

func ExecuteDecodedAMOForm(instruction: bits(48),
                           form: integer {0..PTO_SCALAR_FORM_COUNT-1})
begin
    let operation = ScalarOperationOfForm(form);
    case operation of
        when ScalarOperation_LR_B =>
            ExecuteDecodedLoadReserved(instruction, form, 1);
        when ScalarOperation_LR_H =>
            ExecuteDecodedLoadReserved(instruction, form, 2);
        when ScalarOperation_LR_W =>
            ExecuteDecodedLoadReserved(instruction, form, 4);
        when ScalarOperation_LR_D =>
            ExecuteDecodedLoadReserved(instruction, form, 8);

        when ScalarOperation_SC_B =>
            ExecuteDecodedStoreConditional(instruction, form, 1);
        when ScalarOperation_SC_H =>
            ExecuteDecodedStoreConditional(instruction, form, 2);
        when ScalarOperation_SC_W =>
            ExecuteDecodedStoreConditional(instruction, form, 4);
        when ScalarOperation_SC_D =>
            ExecuteDecodedStoreConditional(instruction, form, 8);

        when ScalarOperation_SWAPB =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 1, TRUE);
        when ScalarOperation_SWAPH =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 2, TRUE);
        when ScalarOperation_SWAPW =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 4, TRUE);
        when ScalarOperation_SWAPD =>
            ExecuteDecodedAtomicReadModifyWrite(
                instruction, form, Atomic_SWAP, 8, TRUE);

        when ScalarOperation_CASB, ScalarOperation_HL_CASB =>
            ExecuteDecodedCompareAndSwap(instruction, form, 1);
        when ScalarOperation_CASH, ScalarOperation_HL_CASH =>
            ExecuteDecodedCompareAndSwap(instruction, form, 2);
        when ScalarOperation_CASW, ScalarOperation_HL_CASW =>
            ExecuteDecodedCompareAndSwap(instruction, form, 4);
        when ScalarOperation_CASD, ScalarOperation_HL_CASD =>
            ExecuteDecodedCompareAndSwap(instruction, form, 8);

        when ScalarOperation_LW_ADD, ScalarOperation_LW_AND,
             ScalarOperation_LW_OR, ScalarOperation_LW_XOR,
             ScalarOperation_LW_SMIN, ScalarOperation_LW_SMAX,
             ScalarOperation_LW_UMIN, ScalarOperation_LW_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 4, TRUE);
        when ScalarOperation_LD_ADD, ScalarOperation_LD_AND,
             ScalarOperation_LD_OR, ScalarOperation_LD_XOR,
             ScalarOperation_LD_SMIN, ScalarOperation_LD_SMAX,
             ScalarOperation_LD_UMIN, ScalarOperation_LD_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 8, TRUE);
        when ScalarOperation_SW_ADD, ScalarOperation_SW_AND,
             ScalarOperation_SW_OR, ScalarOperation_SW_XOR,
             ScalarOperation_SW_SMIN, ScalarOperation_SW_SMAX,
             ScalarOperation_SW_UMIN, ScalarOperation_SW_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 4, FALSE);
        when ScalarOperation_SD_ADD, ScalarOperation_SD_AND,
             ScalarOperation_SD_OR, ScalarOperation_SD_XOR,
             ScalarOperation_SD_SMIN, ScalarOperation_SD_SMAX,
             ScalarOperation_SD_UMIN, ScalarOperation_SD_UMAX =>
            ExecuteDecodedAtomicReadModifyWrite(instruction, form,
                ScalarAtomicOperationForOperation(operation), 8, FALSE);

        when ScalarOperation_DMA =>
            DMA64(
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL),
                ReadDecodedScalarRegister(instruction, form, ScalarField_SrcR));
        otherwise => unreachable;
    end;
end;

func ExecuteScalarInstruction(instruction: bits(48),
                              length_bits: integer {16,32,48})
                              => ScalarExecutionStatus
begin
    let decoded = DecodeScalarForm(instruction, length_bits);
    if decoded == PTO_SCALAR_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_SCALAR_FORM_COUNT-1};
    if !ScalarFormOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    case ScalarFamilyOfForm(form) of
        when ScalarSemantic_ALU => ExecuteDecodedALUForm(instruction, form);
        when ScalarSemantic_AMO => ExecuteDecodedAMOForm(instruction, form);
        when ScalarSemantic_BRU => ExecuteDecodedBRUForm(instruction, form);
        when ScalarSemantic_SYS => ExecuteDecodedSYSForm(instruction, form);
        otherwise => return ScalarExecution_Unsupported;
    end;
    return ScalarExecution_Executed;
end;
