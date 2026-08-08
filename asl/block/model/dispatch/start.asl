// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-START","surface":"block","classification":["model","dispatch","start"],"depends_on":["PTO-BLOCK-MODEL-COMMIT-VALIDATION"]}
readonly func CommandDecodedBundleTarget(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => Word
begin
    let offset = CommandSignedOffsetOfForm(instruction, form);
    return ReadTPC() + LSL(offset, 1);
end;

func ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet,
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1},
    length_bits: integer {16,32,48,64})
begin
    let kind = CommandBundleKindOfForm(form);
    let descriptor = DecodeBundleOperationDescriptor(instruction, form);
    if !BundleOperationDescriptorLegal(descriptor) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    if BundleOperationDescriptorRejectedByAcceptedApplicabilityRules(
        rules, descriptor) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let transfer = if descriptor.branch_type_valid then
        BundleTransferOfBranchType(descriptor.branch_type)
        else CommandBundleTransferOfForm(form);
    let fallthrough = ReadTPC() + (Zeros{PTO_XLEN} + (length_bits DIV 8));
    let target = if transfer == BundleTransfer_Return then _ReturnAddress
        else if transfer == BundleTransfer_Indirect ||
                transfer == BundleTransfer_IndirectCall then _CommitArgument
        else if transfer == BundleTransfer_Fallthrough then fallthrough
        else if CommandHasSignedOffset(form) then
            CommandDecodedBundleTarget(instruction, form)
        else if _BundleBodyAddress != Zeros{PTO_XLEN} then _BundleBodyAddress
        else fallthrough;
    let return_target = if CommandOperandPresent(form, CommandField_uimm5) then
        ReadTPC() + (Zeros{PTO_XLEN} + ((length_bits DIV 8) - 2)) +
        LSL(CommandDecodedWord(instruction, form, CommandField_uimm5), 1)
        else fallthrough;
    let condition = if transfer == BundleTransfer_Conditional then
        !IsZero(ReadBranchPredicate()) else TRUE;
    if target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
        return;
    end;
    if _BundleActive && !CompleteBundleAtWithAcceptedApplicabilityRules(
        rules, ReadTPC()) then
        return;
    end;
    ClearBundleHeaderState();
    BeginBundle(kind, transfer, target, fallthrough, return_target, condition);
    if _LastFault == Fault_None then
        InstallBundleOperationDescriptor(descriptor);
    end;
end;

func ExecuteDecodedBundleStart(instruction: bits(64),
                              form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                              length_bits: integer {16,32,48,64})
begin
    ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None, instruction, form, length_bits);
end;

