// PTO-INSTRUCTION: {"assembly":["BSTOP"],"block":[],"catalog_indices":[51],"catalog_records":[{"asm":"BSTOP","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x00000001","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"bstop_32_d25b09fdd59c","length_bits":32,"mnemonic":"BSTOP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStop","semantic_summary":"Commits the current bundle and transfers to its selected continuation.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["none"],"canonical_assembly":["BSTOP"],"defaults":["The instruction has no encoded operand field and therefore no operand default."],"encoding_class":"standalone-encoded","examples":["BSTOP"],"exceptions":["No active block raises Fault_BundleControl.","Schema, applicability, execution, or final-PC faults reject before block-private state is cleared."],"field_contracts":{},"field_zero_meanings":{},"legality":["All bit patterns not excluded by the form decode are assigned by this instruction contract."],"memory_effects":["Commits every architecture-visible memory effect of the active block before selecting its continuation."],"operands":[],"ordering":["Validate the active block and final BARG continuation, execute the selected block operation, then select BARG.BPCN or the sequential PC and clear block-private state."],"standalone_opcode":true,"state_effects":["Commits the active block, selects BARG.BPCN for DIRECT/CALL/IND/ICALL/RET or taken COND, otherwise selects the sequential PC.","After successful commit, clears BARG, BPC, descriptor fields, dimensions, operand bindings, attributes, and active/body state."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTOP","mnemonic":"BSTOP","summary":"Commits the current bundle and transfers to its selected continuation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstop_32_d25b09fdd59c);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;

pure func InstructionContractCommitsActiveBundle_BSTOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractClearsHeaderState_BSTOP()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
