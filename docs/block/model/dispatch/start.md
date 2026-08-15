<!-- GENERATED FROM: asl/block/model/dispatch/start.asl -->
# Start

**Normative ASL source:** `asl/block/model/dispatch/start.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-START}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/start.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-START","surface":"block","classification":["model","dispatch","start"],"depends_on":["PTO-BLOCK-MODEL-COMMIT-VALIDATION"]}
readonly func CommandDecodedBundleTarget(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => Word
begin
    let offset = CommandSignedOffsetOfForm(instruction, form);
    return ReadTPC() + LSL(offset, 1);
end;

readonly func RetiringBundleBPCNAvailable() => boolean
begin
    return _BundleActive &&
           (_BARG.block_type == BundleKind_Standard ||
            _BARG.block_type == BundleKind_Floating);
end;

func ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet,
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1},
    length_bits: integer {16,32,48,64})
begin
    let instruction_pc = ReadTPC();
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
    let fallthrough = instruction_pc +
        (Zeros{PTO_XLEN} + (length_bits DIV 8));
    let reads_retiring_bpcn =
        transfer == BundleTransfer_Indirect ||
        transfer == BundleTransfer_IndirectCall;
    if reads_retiring_bpcn && !RetiringBundleBPCNAvailable() then
        SetFault(Fault_BundleControl, instruction_pc);
        return;
    end;
    let retiring_bpcn = _BARG.bpcn;
    let target = if transfer == BundleTransfer_Return then _ReturnAddress
        else if reads_retiring_bpcn then retiring_bpcn
        else if transfer == BundleTransfer_Fallthrough then fallthrough
        else if CommandHasSignedOffset(form) then
            CommandDecodedBundleTarget(instruction, form)
        else fallthrough;
    let return_target = if CommandOperandPresent(form, CommandField_uimm5) then
        instruction_pc + (Zeros{PTO_XLEN} + ((length_bits DIV 8) - 2)) +
        LSL(CommandDecodedWord(instruction, form, CommandField_uimm5), 1)
        else fallthrough;
    let taken = transfer != BundleTransfer_Conditional;
    if target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
        return;
    end;
    if _BundleActive && !CompleteBundleAtWithAcceptedApplicabilityRules(
        rules, instruction_pc) then
        return;
    end;
    ClearBundleHeaderState();
    BeginBundleAt(instruction_pc, kind, transfer, target, fallthrough,
        return_target, taken);
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
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
