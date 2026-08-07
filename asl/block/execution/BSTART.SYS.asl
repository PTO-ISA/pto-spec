// PTO-INSTRUCTION: {"assembly":["BSTART.SYS FALL<, fixup_label>"],"block":[],"catalog_indices":[38],"catalog_records":[{"asm":"BSTART.SYS FALL<, fixup_label>","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00001081","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"bstart_sys_32_762d9d84a6d8","length_bits":32,"mnemonic":"BSTART.SYS","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"mnemonic":"BSTART.SYS","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_sys_32_762d9d84a6d8);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
