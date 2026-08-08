// PTO-INSTRUCTION: {"assembly":["FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm"],"block":[],"catalog_indices":[70],"catalog_records":[{"asm":"FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000041","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcBegin","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcEnd","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm","pieces":[{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}],"signedness":"unsigned","width":15}],"form_id":"fentry_32_a47584ec13b6","length_bits":32,"mnemonic":"FENTRY","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteFrameEntry","semantic_summary":"Atomically validates and creates a frame-template entry state.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"FENTRY","summary":"Atomically validates and creates a frame-template entry state.","surface":"block","id":"PTO-BLOCK-FENTRY","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_FENTRY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fentry_32_a47584ec13b6);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FENTRY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameEntry;
end;
// DOC-END: operation
