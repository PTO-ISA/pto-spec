// PTO-INSTRUCTION: {"assembly":["L.BSTART.SYS FALL<, fixup_label>"],"block":[],"catalog_indices":[95],"catalog_records":[{"asm":"L.BSTART.SYS FALL<, fixup_label>","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x0000000f","width_bits":32},{"index":1,"mask":"0x00007fff","match":"0x00001011","width_bits":32}],"encoding_kind":"L64","fields":[{"name":"simm","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":25},{"instruction_lsb":47,"value_lsb":25,"width":17}],"signedness":"signed","width":42}],"form_id":"l_bstart_sys_64_919e576c79e4","length_bits":64,"mnemonic":"L.BSTART.SYS","semantic_family":"BBD","semantic_group":"BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"L.BSTART.SYS","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-L-BSTART-SYS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_L_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_l_bstart_sys_64_919e576c79e4);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_L_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
