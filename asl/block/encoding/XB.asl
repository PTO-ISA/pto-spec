// PTO-INSTRUCTION: {"assembly":["XB ACR-ID, C-ID"],"block":[],"catalog_indices":[98],"catalog_records":[{"asm":"XB ACR-ID, C-ID","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00006f81","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"ACR-ID","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":10}],"signedness":"encoding-defined","width":10},{"name":"CROSS-BID","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7}],"signedness":"encoding-defined","width":7}],"form_id":"xb_32_40ad190a0a7f","length_bits":32,"mnemonic":"XB","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteCrossBlockTransfer","semantic_summary":"Transfers the named context value to a target virtual core block.","status":"accepted"}],"classification":["encoding"],"mnemonic":"XB","summary":"Transfers the named context value to a target virtual core block.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_XB(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_xb_32_40ad190a0a7f);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_XB() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteCrossBlockTransfer;
end;
// DOC-END: operation
