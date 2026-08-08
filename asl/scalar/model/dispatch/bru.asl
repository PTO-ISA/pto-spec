// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-BRU","surface":"scalar","classification":["model","dispatch","bru"],"depends_on":["PTO-SCALAR-MODEL-DISPATCH-DECODE","PTO-SCALAR-MODEL-BRU-SEMANTICS","PTO-SCALAR-ADDTPC","PTO-SCALAR-B-EQ","PTO-SCALAR-B-GE","PTO-SCALAR-B-GEU","PTO-SCALAR-B-LT","PTO-SCALAR-B-LTU","PTO-SCALAR-B-NE","PTO-SCALAR-B-NZ","PTO-SCALAR-B-Z","PTO-SCALAR-C-CMP-EQI","PTO-SCALAR-C-CMP-NEI","PTO-SCALAR-C-SETC-EQ","PTO-SCALAR-C-SETC-NE","PTO-SCALAR-CMP-AND","PTO-SCALAR-CMP-ANDI","PTO-SCALAR-CMP-EQ","PTO-SCALAR-CMP-EQI","PTO-SCALAR-CMP-GE","PTO-SCALAR-CMP-GEI","PTO-SCALAR-CMP-GEU","PTO-SCALAR-CMP-GEUI","PTO-SCALAR-CMP-LT","PTO-SCALAR-CMP-LTI","PTO-SCALAR-CMP-LTU","PTO-SCALAR-CMP-LTUI","PTO-SCALAR-CMP-NE","PTO-SCALAR-CMP-NEI","PTO-SCALAR-CMP-OR","PTO-SCALAR-CMP-ORI","PTO-SCALAR-HL-ADDTPC","PTO-SCALAR-HL-CMP-ANDI","PTO-SCALAR-HL-CMP-EQI","PTO-SCALAR-HL-CMP-GEI","PTO-SCALAR-HL-CMP-GEUI","PTO-SCALAR-HL-CMP-LTI","PTO-SCALAR-HL-CMP-LTUI","PTO-SCALAR-HL-CMP-NEI","PTO-SCALAR-HL-CMP-ORI","PTO-SCALAR-HL-SETC-ANDI","PTO-SCALAR-HL-SETC-EQI","PTO-SCALAR-HL-SETC-GEI","PTO-SCALAR-HL-SETC-GEUI","PTO-SCALAR-HL-SETC-LTI","PTO-SCALAR-HL-SETC-LTUI","PTO-SCALAR-HL-SETC-NEI","PTO-SCALAR-HL-SETC-ORI","PTO-SCALAR-HL-SETRET","PTO-SCALAR-J","PTO-SCALAR-JR","PTO-SCALAR-SETC-AND","PTO-SCALAR-SETC-ANDI","PTO-SCALAR-SETC-EQ","PTO-SCALAR-SETC-EQI","PTO-SCALAR-SETC-GE","PTO-SCALAR-SETC-GEI","PTO-SCALAR-SETC-GEU","PTO-SCALAR-SETC-GEUI","PTO-SCALAR-SETC-LT","PTO-SCALAR-SETC-LTI","PTO-SCALAR-SETC-LTU","PTO-SCALAR-SETC-LTUI","PTO-SCALAR-SETC-NE","PTO-SCALAR-SETC-NEI","PTO-SCALAR-SETC-OR","PTO-SCALAR-SETC-ORI","PTO-SCALAR-SETRET"]}
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
                ReadBranchPredicate(), Zeros{PTO_XLEN},
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
