// PTO-INSTRUCTION: {"assembly":["BSTART.MPAR <VS8, VS16>"],"block":[],"catalog_indices":[28],"catalog_records":[{"asm":"BSTART.MPAR <VS8, VS16>","constraints":[],"encoding":[{"index":0,"mask":"0xf9ffffff","match":"0x00001181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"Mode","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"bstart_mpar_32_2d163417c615","length_bits":32,"mnemonic":"BSTART.MPAR","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"mnemonic":"BSTART.MPAR","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-BSTART-MPAR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_MPAR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mpar_32_2d163417c615);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_MPAR() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
