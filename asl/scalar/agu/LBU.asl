// PTO-INSTRUCTION: {"assembly":["lbu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}"],"block":[],"catalog_indices":[319],"catalog_records":[{"asm":"lbu [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00004009","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"lbu_32_a9a58ab4ea22","length_bits":32,"mnemonic":"LBU","semantic_family":"AGU","semantic_group":"LDA/BASE_REG","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"LBU","summary":"Execute the LBU scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LBU() => ScalarOperation
begin
    return ScalarOperation_LBU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LBU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
