// PTO-INSTRUCTION: {"assembly":["C.BSTART.MSEQ FALL"],"block":[],"catalog_indices":[64],"catalog_records":[{"asm":"C.BSTART.MSEQ FALL","constraints":[],"encoding":[{"index":0,"mask":"0xffff","match":"0x48c0","width_bits":16}],"encoding_kind":"C16","fields":[],"form_id":"c_bstart_mseq_16_b5597e0e41c2","length_bits":16,"mnemonic":"C.BSTART.MSEQ","semantic_family":"BBD","semantic_group":"C.BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"C.BSTART.MSEQ","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART_MSEQ(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_mseq_16_b5597e0e41c2);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_BSTART_MSEQ() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
