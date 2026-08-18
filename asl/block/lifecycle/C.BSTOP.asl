// PTO-INSTRUCTION: {"assembly":["C.BSTOP"],"block":[],"catalog_indices":[59],"catalog_records":[{"asm":"C.BSTOP","constraints":[],"encoding":[{"index":0,"mask":"0xffff","match":"0x0000","width_bits":16}],"encoding_kind":"C16","fields":[],"form_id":"c_bstop_16_ca4743d8a95e","length_bits":16,"mnemonic":"C.BSTOP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStop","semantic_summary":"Commits the current bundle and transfers to its selected continuation.","status":"accepted"}],"classification":["lifecycle"],"contract":{"block_composition":["none"],"canonical_assembly":["C.BSTOP"],"defaults":["The instruction has no encoded operand field and therefore no operand default."],"encoding_class":"standalone-encoded","examples":["C.BSTOP"],"exceptions":["No active block raises Fault_BundleControl.","Schema, applicability, execution, or final-PC faults reject before block-private state is cleared."],"field_contracts":{},"field_zero_meanings":{},"legality":["All bit patterns not excluded by the form decode are assigned by this instruction contract."],"memory_effects":["Commits every architecture-visible memory effect of the active block before selecting its continuation."],"operands":[],"ordering":["Validate the active block and final BARG continuation, execute the selected block operation, then select BARG.BPCN or the sequential PC and clear block-private state."],"standalone_opcode":true,"state_effects":["Commits the active block, selects BARG.BPCN for DIRECT/CALL/IND/ICALL/RET or taken COND, otherwise selects the sequential PC.","After successful commit, clears BARG, BPC, descriptor fields, dimensions, operand bindings, attributes, and active/body state."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-C-BSTOP","mnemonic":"C.BSTOP","summary":"Commits the current bundle and transfers to its selected continuation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-C-BSTOP-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=block status=accepted
// C.BSTOP MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-C-BSTOP-DECISION-BINDING-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstop_16_ca4743d8a95e);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;

pure func InstructionContractCommitsActiveBundle_C_BSTOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractClearsHeaderState_C_BSTOP()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
