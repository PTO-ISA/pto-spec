// PTO-INSTRUCTION: {"assembly":["C.BSTOP"],"block":[],"catalog_indices":[67],"catalog_records":[{"asm":"C.BSTOP","constraints":[],"encoding":[{"index":0,"mask":"0xffff","match":"0x0000","width_bits":16}],"encoding_kind":"C16","fields":[],"form_id":"c_bstop_16_ca4743d8a95e","length_bits":16,"mnemonic":"C.BSTOP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStop","semantic_summary":"Commits the current bundle and transfers to its selected continuation.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"C.BSTOP","summary":"Commits the current bundle and transfers to its selected continuation.","surface":"block"}
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
// DOC-END: operation
