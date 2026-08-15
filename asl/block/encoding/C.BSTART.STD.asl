// PTO-INSTRUCTION: {"assembly":["C.BSTART.STD {FALL, IND, RET}"],"block":[],"catalog_indices":[57],"catalog_records":[{"asm":"C.BSTART.STD {FALL, IND, RET}","constraints":[{"field":"BrType","operator":"one-of","values":[1,5,7]}],"encoding":[{"index":0,"mask":"0xc7ff","match":"0x0000","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"BrType","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3}],"form_id":"c_bstart_std_16_8b40f078c14a","length_bits":16,"mnemonic":"C.BSTART.STD","semantic_family":"BBD","semantic_group":"C.BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts a compressed STD block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.","status":"accepted","excluded_value_owners":[{"field":"BrType","value":0,"owner":"C.BSTOP"}]}],"classification":["encoding"],"contract":{"block_composition":["After any active predecessor block commits successfully, C.BSTART.STD opens one Standard block. FALL and RET may start without a predecessor; IND requires an active retiring Standard or Floating BARG."],"canonical_assembly":["C.BSTART.STD FALL","C.BSTART.STD IND","C.BSTART.STD RET"],"defaults":["BrType is always encoded; it has no omitted or default form."],"encoding_class":"standalone-encoded","examples":["C.BSTART.STD FALL","C.BSTART.STD IND","C.BSTART.STD RET"],"exceptions":["BrType code 0 is C.BSTOP. Codes 2, 3, 4, and 6 do not decode as standalone C.BSTART.STD and raise Fault_IllegalInstruction before effects.","IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects. An odd snapshotted BARG.BPCN or return address raises Fault_InstructionPC before predecessor retirement.","If predecessor commit fails, the retiring block remains authoritative and no Standard BARG is installed."],"field_contracts":{},"field_zero_meanings":{"BrType":"Encoded zero is owned by C.BSTOP, not C.BSTART.STD."},"legality":["c_bstart_std_16_8b40f078c14a.BrType accepts exactly 1 (FALL), 5 (IND), or 7 (RET). Code 0 decodes as C.BSTOP, while codes 2, 3, 4, and 6 do not decode as standalone C.BSTART.STD; code 6 is used only inside fused BSTART.ICALL."],"memory_effects":["none"],"operands":[{"field":"BrType","role":"encoded transfer kind: FALL, IND, or RET"}],"ordering":["Decode and transfer legality precede source selection. IND snapshots retiring BARG.BPCN and RET snapshots architectural ra before predecessor retirement.","Target alignment is checked before retirement; the new Standard BARG is installed only after successful retirement."],"standalone_opcode":true,"state_effects":["FALL installs a non-selecting sequential Standard BARG. IND installs the snapshotted retiring BARG.BPCN; RET installs the snapshotted architectural return address.","The installed candidate continuation remains pending until BSTOP or the next BSTART commits the new block."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-C-BSTART-STD","mnemonic":"C.BSTART.STD","summary":"Starts a compressed STD block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-C-BSTART-STD-CONTROL-001
// ndf: kind=contract level=L1 layer=block status=accepted
// C.BSTART.STD MUST accept exactly FALL, IND, and RET. IND MUST snapshot the
// retiring standard-or-floating BARG.BPCN before commit. BrType zero remains
// C.BSTOP; every other unassigned BrType MUST raise Fault_IllegalInstruction
// before effects.
// NDF-END: PTO-C-BSTART-STD-CONTROL-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_std_16_8b40f078c14a);
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractBranchTypeLegal_C_BSTART_STD(
    branch_type: bits(3))
    => boolean
begin
    return branch_type == '001' ||
           branch_type == '101' ||
           branch_type == '111';
end;

pure func InstructionContractTransfer_C_BSTART_STD(
    branch_type: bits(3))
    => BundleTransfer
begin
    assert InstructionContractBranchTypeLegal_C_BSTART_STD(branch_type);
    if branch_type == '001' then
        return BundleTransfer_Fallthrough;
    elsif branch_type == '101' then
        return BundleTransfer_Indirect;
    else
        return BundleTransfer_Return;
    end;
end;

readonly func InstructionContractHandler_C_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
