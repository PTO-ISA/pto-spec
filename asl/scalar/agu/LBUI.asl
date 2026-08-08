// PTO-INSTRUCTION: {"assembly":["lbui [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[321],"catalog_records":[{"asm":"lbui [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00004019","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"lbui_32_c39b9aa11f02","length_bits":32,"mnemonic":"LBUI","semantic_family":"AGU","semantic_group":"LDA/BASE_IMM","semantic_handler":"ExecuteScalarLoad","status":"accepted","semantic_summary":"LBUI - Load scalar data using this mnemonic's width, signedness, and address-update form."}],"classification":["agu"],"mnemonic":"LBUI","summary":"LBUI - Load scalar data using this mnemonic's width, signedness, and address-update form.","surface":"scalar","id":"PTO-SCALAR-LBUI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LBUI() => ScalarOperation
begin
    return ScalarOperation_LBUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LBUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
