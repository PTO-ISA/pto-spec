// PTO-INSTRUCTION: {"assembly":["lbi [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[318],"catalog_records":[{"asm":"lbi [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000019","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"lbi_32_9af2cdbeb38f","length_bits":32,"mnemonic":"LBI","semantic_family":"AGU","semantic_group":"LDA/BASE_IMM","semantic_handler":"ExecuteScalarLoad","status":"accepted","semantic_summary":"LBI - Load scalar data using this mnemonic's width, signedness, and address-update form."}],"classification":["agu"],"mnemonic":"LBI","summary":"LBI - Load scalar data using this mnemonic's width, signedness, and address-update form.","surface":"scalar","id":"PTO-SCALAR-LBI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LBI() => ScalarOperation
begin
    return ScalarOperation_LBI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LBI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
