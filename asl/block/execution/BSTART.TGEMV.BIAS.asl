// PTO-INSTRUCTION: {"assembly":["BSTART.TGEMV.BIAS DataType"],"block":[],"catalog_indices":[42],"catalog_records":[{"asm":"BSTART.TGEMV.BIAS DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x01131181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tgemv_bias_32_186ee96c0a8b","length_bits":32,"mnemonic":"BSTART.TGEMV.BIAS","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["execution"],"mnemonic":"BSTART.TGEMV.BIAS","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TGEMV_BIAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tgemv_bias_32_186ee96c0a8b);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_TGEMV_BIAS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
