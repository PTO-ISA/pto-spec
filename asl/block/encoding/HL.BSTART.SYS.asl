// PTO-INSTRUCTION: {"assembly":["HL.BSTART.SYS FALL<, fixup_label>"],"block":[],"catalog_indices":[83],"catalog_records":[{"asm":"HL.BSTART.SYS FALL<, fixup_label>","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff000f","match":"0x00001081000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"simm","pieces":[{"instruction_lsb":31,"value_lsb":1,"width":17},{"instruction_lsb":4,"value_lsb":18,"width":12}],"signedness":"signed","width":30}],"form_id":"hl_bstart_sys_48_5bf0381f7bf8","length_bits":48,"mnemonic":"HL.BSTART.SYS","semantic_family":"BBD","semantic_group":"BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"HL.BSTART.SYS","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-HL-BSTART-SYS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_HL_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_sys_48_5bf0381f7bf8);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
