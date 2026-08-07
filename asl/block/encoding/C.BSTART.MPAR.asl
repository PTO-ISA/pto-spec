// PTO-INSTRUCTION: {"assembly":["C.BSTART.MPAR FALL"],"block":[],"catalog_indices":[63],"catalog_records":[{"asm":"C.BSTART.MPAR FALL","constraints":[],"encoding":[{"index":0,"mask":"0xffff","match":"0x08c0","width_bits":16}],"encoding_kind":"C16","fields":[],"form_id":"c_bstart_mpar_16_66c3ef2226ec","length_bits":16,"mnemonic":"C.BSTART.MPAR","semantic_family":"BBD","semantic_group":"C.BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"C.BSTART.MPAR","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART_MPAR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_mpar_16_66c3ef2226ec);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_BSTART_MPAR() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
