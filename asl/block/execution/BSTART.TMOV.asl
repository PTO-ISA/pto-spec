// PTO-INSTRUCTION: {"assembly":["BSTART.TMOV DataType"],"block":[],"catalog_indices":[53],"catalog_records":[{"asm":"BSTART.TMOV DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,31]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00211181","width_bits":32}],"encoding_kind":"L32","encoding_variants":[{"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00911181","width_bits":32}],"function":9,"name":"TMOV.L2S.INSERT"},{"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00a11181","width_bits":32}],"function":10,"name":"TMOV.L2S.PUBLISH"},{"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00b11181","width_bits":32}],"function":11,"name":"TMOV.S2L.BROADCAST"},{"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00c11181","width_bits":32}],"function":12,"name":"TMOV.S2L.EXTRACT"}],"fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tmov_32_211446509efb","length_bits":32,"mnemonic":"BSTART.TMOV","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"mnemonic":"BSTART.TMOV","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-BSTART-TMOV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TMOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tmov_32_211446509efb);
end;
// DOC-END: decode
// DOC-BEGIN: operation
// BSTART.TMOV accepts DTYPE_NONE (encoded 31). When neither B.DATR nor BSTART
// contributes a concrete type, Local/Shared TMOV inherits the bound source
// descriptor type. DTYPE_NONE is never installed in a tile descriptor.
readonly func InstructionContractHandler_BSTART_TMOV() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
