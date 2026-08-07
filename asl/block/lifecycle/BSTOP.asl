// PTO-INSTRUCTION: {"assembly":["BSTOP"],"block":[],"catalog_indices":[57],"catalog_records":[{"asm":"BSTOP","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x00000001","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"bstop_32_d25b09fdd59c","length_bits":32,"mnemonic":"BSTOP","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStop","semantic_summary":"Commits the current bundle and transfers to its selected continuation.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"BSTOP","summary":"Commits the current bundle and transfers to its selected continuation.","surface":"block"}
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
// DOC-END: operation
