// PTO-INSTRUCTION: {"assembly":["lb [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}"],"block":[],"catalog_indices":[316],"catalog_records":[{"asm":"lb [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000009","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"lb_32_b718aa88e28f","length_bits":32,"mnemonic":"LB","semantic_family":"AGU","semantic_group":"LDA/BASE_REG","semantic_handler":"ExecuteScalarLoad","status":"accepted","semantic_summary":"LB - Load scalar data using this mnemonic's width, signedness, and address-update form."}],"classification":["agu"],"mnemonic":"LB","summary":"LB - Load scalar data using this mnemonic's width, signedness, and address-update form.","surface":"scalar","id":"PTO-SCALAR-LB","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LB() => ScalarOperation
begin
    return ScalarOperation_LB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LB() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
