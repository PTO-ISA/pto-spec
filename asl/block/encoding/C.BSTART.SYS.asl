// PTO-INSTRUCTION: {"assembly":["C.BSTART.SYS FALL"],"block":[],"catalog_indices":[66],"catalog_records":[{"asm":"C.BSTART.SYS FALL","constraints":[],"encoding":[{"index":0,"mask":"0xffff","match":"0x0840","width_bits":16}],"encoding_kind":"C16","fields":[],"form_id":"c_bstart_sys_16_ec213ce96eb7","length_bits":16,"mnemonic":"C.BSTART.SYS","semantic_family":"BBD","semantic_group":"C.BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"C.BSTART.SYS","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-C-BSTART-SYS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_sys_16_ec213ce96eb7);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
