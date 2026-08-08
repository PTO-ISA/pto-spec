// PTO-INSTRUCTION: {"assembly":["MSET [RegSrc0, RegSrc1, RegSrc2]"],"block":[],"catalog_indices":[97],"catalog_records":[{"asm":"MSET [RegSrc0, RegSrc1, RegSrc2]","constraints":[],"encoding":[{"index":0,"mask":"0x06007fff","match":"0x00001031","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"mset_32_0b932f291932","length_bits":32,"mnemonic":"MSET","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteMemorySet","semantic_summary":"Fills an encoded memory range after complete access preflight.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"MSET","summary":"Fills an encoded memory range after complete access preflight.","surface":"block","id":"PTO-BLOCK-MSET","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_MSET(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_mset_32_0b932f291932);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MSET() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemorySet;
end;
// DOC-END: operation
