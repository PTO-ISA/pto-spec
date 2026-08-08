// PTO-INSTRUCTION: {"assembly":["sd SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<3]"],"block":[],"catalog_indices":[393],"catalog_records":[{"asm":"sd SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<3]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00003049","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"sd_32_9dbc40328653","length_bits":32,"mnemonic":"SD","semantic_family":"AGU","semantic_group":"STA/BASE_REG","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SD","summary":"Execute the SD scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SD","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SD() => ScalarOperation
begin
    return ScalarOperation_SD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SD() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
