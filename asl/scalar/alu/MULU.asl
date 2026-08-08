// PTO-INSTRUCTION: {"assembly":["mulu SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[371],"catalog_records":[{"asm":"mulu SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00001047","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"mulu_32_10b9d1936631","length_bits":32,"mnemonic":"MULU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MultiplyWord","status":"accepted","semantic_summary":"MULU - Compute the scalar product."}],"classification":["alu"],"mnemonic":"MULU","summary":"MULU - Compute the scalar product.","surface":"scalar","id":"PTO-SCALAR-MULU","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MULU() => ScalarOperation
begin
    return ScalarOperation_MULU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MULU() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
// DOC-END: operation
