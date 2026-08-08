// PTO-INSTRUCTION: {"assembly":["BSTART.CALL <br_label>, <rt_label>, ->ra"],"block":[],"catalog_indices":[16],"catalog_records":[{"asm":"BSTART.CALL <br_label>, <rt_label>, ->ra","constraints":[],"encoding":[{"index":0,"mask":"0xf83f000f","match":"0x50160002","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm12","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":12}],"signedness":"signed","width":12},{"name":"uimm5","pieces":[{"instruction_lsb":22,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"bstart_call_32_9404418d1ae5","length_bits":32,"mnemonic":"BSTART CALL","semantic_family":"BBD","semantic_group":"BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"mnemonic":"BSTART CALL","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-BSTART-CALL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_call_32_9404418d1ae5);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_CALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
