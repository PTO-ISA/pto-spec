// PTO-INSTRUCTION: {"assembly":["BSTART.MSEQ <VS8, VS16>"],"block":[],"catalog_indices":[30],"catalog_records":[{"asm":"BSTART.MSEQ <VS8, VS16>","constraints":[],"encoding":[{"index":0,"mask":"0xf9ffffff","match":"0x00009181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"Mode","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"bstart_mseq_32_39343a456ec5","length_bits":32,"mnemonic":"BSTART.MSEQ","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"mnemonic":"BSTART.MSEQ","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_MSEQ(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mseq_32_39343a456ec5);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_MSEQ() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
