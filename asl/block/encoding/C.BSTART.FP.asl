// PTO-INSTRUCTION: {"assembly":["C.BSTART.FP {FALL, IND, RET}"],"block":[],"catalog_indices":[56],"catalog_records":[{"asm":"C.BSTART.FP {FALL, IND, RET}","constraints":[{"field":"BrType","operator":"one-of","values":[1,5,7]}],"encoding":[{"index":0,"mask":"0xc7ff","match":"0x0080","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"BrType","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3}],"form_id":"c_bstart_fp_16_9dcef7e3a85b","length_bits":16,"mnemonic":"C.BSTART.FP","semantic_family":"BBD","semantic_group":"C.BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts a compressed FP block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.","status":"accepted"}],"classification":["encoding"],"contract":{"block_composition":["After any active predecessor block commits successfully, C.BSTART.FP opens one Floating block. FALL and RET may start without a predecessor; IND requires an active retiring Standard or Floating BARG."],"canonical_assembly":["C.BSTART.FP FALL","C.BSTART.FP IND","C.BSTART.FP RET"],"defaults":["BrType is always encoded; it has no omitted or default form."],"encoding_class":"standalone-encoded","examples":["C.BSTART.FP FALL","C.BSTART.FP IND","C.BSTART.FP RET"],"exceptions":["BrType codes 0, 2, 3, 4, and 6 do not decode as standalone C.BSTART.FP and raise Fault_IllegalInstruction before effects.","IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects. An odd snapshotted BARG.BPCN or return address raises Fault_InstructionPC before predecessor retirement.","If predecessor commit fails, the retiring block remains authoritative and no Floating BARG is installed."],"field_contracts":{},"field_zero_meanings":{"BrType":"Encoded zero is reserved and rejected."},"legality":["c_bstart_fp_16_9dcef7e3a85b.BrType accepts exactly 1 (FALL), 5 (IND), or 7 (RET); code 6 is only the embedded low halfword of fused BSTART.ICALL and is illegal as a standalone 16-bit instruction."],"memory_effects":["none"],"operands":[{"field":"BrType","role":"encoded transfer kind: FALL, IND, or RET"}],"ordering":["Decode and transfer legality precede source selection. IND snapshots retiring BARG.BPCN and RET snapshots architectural ra before predecessor retirement.","Target alignment is checked before retirement; the new Floating BARG is installed only after successful retirement."],"standalone_opcode":true,"state_effects":["FALL installs a non-selecting sequential Floating BARG. IND installs the snapshotted retiring BARG.BPCN; RET installs the snapshotted architectural return address.","The installed candidate continuation remains pending until BSTOP or the next BSTART commits the new block."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-C-BSTART-FP","mnemonic":"C.BSTART.FP","summary":"Starts a compressed FP block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-C-BSTART-FP-CONTROL-001
// ndf: kind=contract level=L1 layer=block status=accepted
// C.BSTART.FP MUST accept exactly FALL, IND, and RET. IND MUST snapshot the
// retiring standard-or-floating BARG.BPCN before commit. Every BrType that is
// not assigned to another standalone mnemonic MUST raise
// Fault_IllegalInstruction before effects.
// NDF-END: PTO-C-BSTART-FP-CONTROL-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_fp_16_9dcef7e3a85b);
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractBranchTypeLegal_C_BSTART_FP(
    branch_type: bits(3))
    => boolean
begin
    return branch_type == '001' ||
           branch_type == '101' ||
           branch_type == '111';
end;

pure func InstructionContractTransfer_C_BSTART_FP(
    branch_type: bits(3))
    => BundleTransfer
begin
    assert InstructionContractBranchTypeLegal_C_BSTART_FP(branch_type);
    if branch_type == '001' then
        return BundleTransfer_Fallthrough;
    elsif branch_type == '101' then
        return BundleTransfer_Indirect;
    else
        return BundleTransfer_Return;
    end;
end;

readonly func InstructionContractHandler_C_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
