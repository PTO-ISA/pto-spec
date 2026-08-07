// PTO-INSTRUCTION: {"assembly":["C.BSTART.FP BrType"],"block":[],"catalog_indices":[62],"catalog_records":[{"asm":"C.BSTART.FP BrType","constraints":[{"field":"BrType","operator":"not-equal","value":0}],"encoding":[{"index":0,"mask":"0xc7ff","match":"0x0080","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"BrType","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":3}],"signedness":"encoding-defined","width":3}],"form_id":"c_bstart_fp_16_9dcef7e3a85b","length_bits":16,"mnemonic":"C.BSTART.FP","semantic_family":"BBD","semantic_group":"C.BSTART","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"C.BSTART.FP","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_fp_16_9dcef7e3a85b);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
