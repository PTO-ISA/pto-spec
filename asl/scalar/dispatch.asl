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
    if ScalarFamilyOfForm(form) != ScalarSemantic_ALU then
        return ScalarExecution_Unsupported;
    end;
    ExecuteDecodedALUForm(instruction, form);
    return ScalarExecution_Executed;
end;
