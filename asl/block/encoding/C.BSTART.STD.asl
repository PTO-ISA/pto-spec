// PTO-INSTRUCTION: {"assembly":["C.BSTART.STD BrType"],"block":[],"catalog_indices":[65],"catalog_records":[{"asm":"C.BSTART.STD BrType","constraints":[{"field":"BrType","operator":"not-equal","value":0}],"encoding":[{"index":0,"mask":"0xc7ff","match":"0x0000","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"BrType","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3}],"form_id":"c_bstart_std_16_8b40f078c14a","length_bits":16,"mnemonic":"C.BSTART.STD","semantic_family":"BBD","semantic_group":"C.BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"C.BSTART.STD","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_std_16_8b40f078c14a);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
