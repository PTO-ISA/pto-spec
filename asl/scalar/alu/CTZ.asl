// PTO-INSTRUCTION: {"assembly":["ctz SrcL,  M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[80],"catalog_records":[{"asm":"ctz SrcL,  M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00004067","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imml","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"ctz_32_1761cbcc2a89","length_bits":32,"mnemonic":"CTZ","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"CountBitfield","status":"accepted"}],"classification":["alu"],"mnemonic":"CTZ","summary":"Execute the CTZ scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-CTZ","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CTZ() => ScalarOperation
begin
    return ScalarOperation_CTZ;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CTZ() => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;
// DOC-END: operation
