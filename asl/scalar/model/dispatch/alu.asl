// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-ALU","surface":"scalar","classification":["model","dispatch","alu"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-ALU-SEMANTICS","PTO-SCALAR-ADD","PTO-SCALAR-ADDI","PTO-SCALAR-ADDIW","PTO-SCALAR-ADDW","PTO-SCALAR-AND","PTO-SCALAR-ANDI","PTO-SCALAR-ANDIW","PTO-SCALAR-ANDW","PTO-SCALAR-BCNT","PTO-SCALAR-BIC","PTO-SCALAR-BIS","PTO-SCALAR-BXS","PTO-SCALAR-BXU","PTO-SCALAR-C-ADD","PTO-SCALAR-C-ADDI","PTO-SCALAR-C-AND","PTO-SCALAR-C-MOVI","PTO-SCALAR-C-MOVR","PTO-SCALAR-C-OR","PTO-SCALAR-C-SETC-TGT","PTO-SCALAR-C-SETRET","PTO-SCALAR-C-SEXT-B","PTO-SCALAR-C-SEXT-H","PTO-SCALAR-C-SEXT-W","PTO-SCALAR-C-SLLI","PTO-SCALAR-C-SRLI","PTO-SCALAR-C-SUB","PTO-SCALAR-C-ZEXT-B","PTO-SCALAR-C-ZEXT-H","PTO-SCALAR-C-ZEXT-W","PTO-SCALAR-CLZ","PTO-SCALAR-CSEL","PTO-SCALAR-CTZ","PTO-SCALAR-DIV","PTO-SCALAR-DIVU","PTO-SCALAR-DIVUW","PTO-SCALAR-DIVW","PTO-SCALAR-HL-ADDI","PTO-SCALAR-HL-ADDIW","PTO-SCALAR-HL-ANDI","PTO-SCALAR-HL-ANDIW","PTO-SCALAR-HL-BFI","PTO-SCALAR-HL-CCAT","PTO-SCALAR-HL-CCATW","PTO-SCALAR-HL-DIV","PTO-SCALAR-HL-DIVU","PTO-SCALAR-HL-DIVUW","PTO-SCALAR-HL-DIVW","PTO-SCALAR-HL-LIS","PTO-SCALAR-HL-LIU","PTO-SCALAR-HL-LUI","PTO-SCALAR-HL-MADD","PTO-SCALAR-HL-MADDW","PTO-SCALAR-HL-MIADD","PTO-SCALAR-HL-MISUB","PTO-SCALAR-HL-MUL","PTO-SCALAR-HL-MULU","PTO-SCALAR-HL-ORI","PTO-SCALAR-HL-ORIW","PTO-SCALAR-HL-REM","PTO-SCALAR-HL-REMU","PTO-SCALAR-HL-REMUW","PTO-SCALAR-HL-REMW","PTO-SCALAR-HL-SUBI","PTO-SCALAR-HL-SUBIW","PTO-SCALAR-HL-XORI","PTO-SCALAR-HL-XORIW","PTO-SCALAR-LUI","PTO-SCALAR-MADD","PTO-SCALAR-MADDW","PTO-SCALAR-MAX","PTO-SCALAR-MAXU","PTO-SCALAR-MIN","PTO-SCALAR-MINU","PTO-SCALAR-MUL","PTO-SCALAR-MULU","PTO-SCALAR-MULUW","PTO-SCALAR-MULW","PTO-SCALAR-OR","PTO-SCALAR-ORI","PTO-SCALAR-ORIW","PTO-SCALAR-ORW","PTO-SCALAR-REM","PTO-SCALAR-REMU","PTO-SCALAR-REMUW","PTO-SCALAR-REMW","PTO-SCALAR-REV","PTO-SCALAR-SLL","PTO-SCALAR-SLLI","PTO-SCALAR-SLLIW","PTO-SCALAR-SLLW","PTO-SCALAR-SRA","PTO-SCALAR-SRAI","PTO-SCALAR-SRAIW","PTO-SCALAR-SRAW","PTO-SCALAR-SRL","PTO-SCALAR-SRLI","PTO-SCALAR-SRLIW","PTO-SCALAR-SRLW","PTO-SCALAR-SUB","PTO-SCALAR-SUBI","PTO-SCALAR-SUBIW","PTO-SCALAR-SUBW","PTO-SCALAR-XOR","PTO-SCALAR-XORI","PTO-SCALAR-XORIW","PTO-SCALAR-XORW"]}
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
                MoveScalarValue(
                    ScalarDecodedWord(instruction, form, ScalarField_simm5)));
        when ScalarOperation_C_MOVR =>
            WriteScalarDestination(
                ScalarDecodedSelector(instruction, form, ScalarField_RegDst),
                MoveScalarValue(
                    ReadDecodedScalarRegister(instruction, form, ScalarField_SrcL)));

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

