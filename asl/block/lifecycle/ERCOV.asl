// PTO-INSTRUCTION: {"assembly":["ERCOV [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]"],"block":[],"catalog_indices":[68],"catalog_records":[{"asm":"ERCOV [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]","constraints":[],"encoding":[{"index":0,"mask":"0x06007fff","match":"0x00003031","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegSrc0","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc1","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegSrc2","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"ercov_32_dc0be14a2d8b","length_bits":32,"mnemonic":"ERCOV","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"RecoverExecutionContext","semantic_summary":"Recovers the encoded execution-context range from memory.","status":"accepted"}],"classification":["lifecycle"],"mnemonic":"ERCOV","summary":"Recovers the encoded execution-context range from memory.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_ERCOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_ercov_32_dc0be14a2d8b);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ERCOV() => CommandSemanticHandler
begin
    return CommandHandler_RecoverExecutionContext;
end;
// DOC-END: operation
