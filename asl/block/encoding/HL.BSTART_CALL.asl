// PTO-INSTRUCTION: {"assembly":["HL.BSTART.CALL <br_label>, <rt_label>, ->ra"],"block":[],"catalog_indices":[74],"catalog_records":[{"asm":"HL.BSTART.CALL <br_label>, <rt_label>, ->ra","constraints":[],"encoding":[{"index":0,"mask":"0xf83f0000007f","match":"0x501600000011","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"simm25","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":25}],"signedness":"signed","width":25},{"name":"uimm5","pieces":[{"instruction_lsb":38,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"hl_bstart_call_48_3c784c583c90","length_bits":48,"mnemonic":"HL.BSTART CALL","semantic_family":"BBD","semantic_group":"BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"HL.BSTART CALL","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-HL-BSTART-CALL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_HL_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_bstart_call_48_3c784c583c90);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_BSTART_CALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
