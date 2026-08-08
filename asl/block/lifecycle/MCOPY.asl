// PTO-INSTRUCTION: {"assembly":["MCOPY [RegSrc0, RegSrc1, RegSrc2]"],"block":[],"catalog_indices":[96],"catalog_records":[{"asm":"MCOPY [RegSrc0, RegSrc1, RegSrc2]","constraints":[],"encoding":[{"index":0,"mask":"0x06007fff","match":"0x00000031","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"mcopy_32_4fc4a803e995","length_bits":32,"mnemonic":"MCOPY","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteMemoryCopy","semantic_summary":"Copies an encoded memory range with instruction-atomic preflight and snapshot semantics.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"MCOPY","summary":"Copies an encoded memory range with instruction-atomic preflight and snapshot semantics.","surface":"block","id":"PTO-BLOCK-MCOPY","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_MCOPY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_mcopy_32_4fc4a803e995);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MCOPY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemoryCopy;
end;
// DOC-END: operation
