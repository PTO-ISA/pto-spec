// PTO-INSTRUCTION: {"assembly":["BSTART.TSTORE DataType"],"block":[],"catalog_indices":[56],"catalog_records":[{"asm":"BSTART.TSTORE DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00111181","width_bits":32}],"encoding_kind":"L32","encoding_variants":[{"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00e11181","width_bits":32}],"function":14,"name":"TSTORE.SPART"}],"fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tstore_32_4048b6e8b0f4","length_bits":32,"mnemonic":"BSTART.TSTORE","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"mnemonic":"BSTART.TSTORE","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-BSTART-TSTORE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TSTORE(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tstore_32_4048b6e8b0f4);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_TSTORE() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
