// PTO-INSTRUCTION: {"assembly":["BSTART {DIRECT, CALL}, <label>","BSTART COND, <label>"],"block":[],"catalog_indices":[14,15],"catalog_records":[{"asm":"BSTART {DIRECT, CALL}, <label>","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000011","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm25","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":25}],"signedness":"signed","width":25}],"form_id":"bstart_32_7eb93b649748","length_bits":32,"mnemonic":"BSTART","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"},{"asm":"BSTART COND, <label>","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000021","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm25","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":25}],"signedness":"signed","width":25}],"form_id":"bstart_32_e11e678a32ac","length_bits":32,"mnemonic":"BSTART","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"BSTART","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-BSTART","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_32_7eb93b649748) ||
           (operation == CommandOperation_bstart_32_e11e678a32ac);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
