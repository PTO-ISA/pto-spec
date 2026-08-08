// PTO-INSTRUCTION: {"assembly":["clz SrcL,  M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[62],"catalog_records":[{"asm":"clz SrcL,  M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00005067","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imml","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"clz_32_f890415c15b6","length_bits":32,"mnemonic":"CLZ","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"CountBitfield","status":"accepted"}],"classification":["alu"],"mnemonic":"CLZ","summary":"Execute the CLZ scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-CLZ","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CLZ() => ScalarOperation
begin
    return ScalarOperation_CLZ;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CLZ() => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;
// DOC-END: operation
