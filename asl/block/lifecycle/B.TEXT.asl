// PTO-INSTRUCTION: {"assembly":["B.TEXT <label>"],"block":[],"catalog_indices":[13],"catalog_records":[{"asm":"B.TEXT <label>","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000003","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm25","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":25}],"signedness":"signed","width":25}],"form_id":"b_text_32_1ce09f50e5dd","length_bits":32,"mnemonic":"B.TEXT","semantic_family":"CMD","semantic_group":"Bundle Offset","semantic_handler":"SetBundleBodyAddress","semantic_summary":"Sets the out-of-line body entry address for a decoupled bundle.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"B.TEXT","summary":"Sets the out-of-line body entry address for a decoupled bundle.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_B_TEXT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_text_32_1ce09f50e5dd);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_TEXT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleBodyAddress;
end;
// DOC-END: operation
