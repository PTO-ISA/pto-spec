// PTO-INSTRUCTION: {"assembly":["C.BSTART COND,  label","C.BSTART DIRECT, label"],"block":[],"catalog_indices":[60,61],"catalog_records":[{"asm":"C.BSTART COND,  label","constraints":[],"encoding":[{"index":0,"mask":"0x000f","match":"0x0004","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"simm12","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"c_bstart_16_c4e238a9227a","length_bits":16,"mnemonic":"C.BSTART","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"},{"asm":"C.BSTART DIRECT, label","constraints":[],"encoding":[{"index":0,"mask":"0x000f","match":"0x0002","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"simm12","pieces":[{"instruction_lsb":4,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"c_bstart_16_f833d2a4753c","length_bits":16,"mnemonic":"C.BSTART","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","status":"accepted"}],"classification":["encoding"],"mnemonic":"C.BSTART","summary":"Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.","surface":"block","id":"PTO-BLOCK-C-BSTART","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_C_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_16_c4e238a9227a) ||
           (operation == CommandOperation_c_bstart_16_f833d2a4753c);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
