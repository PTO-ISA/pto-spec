// PTO-INSTRUCTION: {"assembly":["ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]"],"block":[],"catalog_indices":[69],"catalog_records":[{"asm":"ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]","constraints":[],"encoding":[{"index":0,"mask":"0x06007fff","match":"0x00002031","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"esave_32_4c4f79fe3171","length_bits":32,"mnemonic":"ESAVE","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"SaveExecutionContext","semantic_summary":"Saves the encoded execution-context range to memory.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"ESAVE","summary":"Saves the encoded execution-context range to memory.","surface":"block","id":"PTO-BLOCK-ESAVE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_ESAVE(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_esave_32_4c4f79fe3171);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ESAVE() => CommandSemanticHandler
begin
    return CommandHandler_SaveExecutionContext;
end;
// DOC-END: operation
