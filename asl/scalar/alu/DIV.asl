// PTO-INSTRUCTION: {"assembly":["div SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[90],"catalog_records":[{"asm":"div SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00000057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"div_32_a6efe85f8662","length_bits":32,"mnemonic":"DIV","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarDivideSigned","status":"accepted","semantic_summary":"DIV - Compute signed scalar quotient."}],"classification":["alu"],"mnemonic":"DIV","summary":"DIV - Compute signed scalar quotient.","surface":"scalar","id":"PTO-SCALAR-DIV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DIV() => ScalarOperation
begin
    return ScalarOperation_DIV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSigned;
end;
// DOC-END: operation
