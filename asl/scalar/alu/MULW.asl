// PTO-INSTRUCTION: {"assembly":["mulw SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[373],"catalog_records":[{"asm":"mulw SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00002047","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"mulw_32_b90cb6a30a23","length_bits":32,"mnemonic":"MULW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarMultiplyW","status":"accepted","semantic_summary":"MULW - Compute the 32-bit product and sign-extend it."}],"classification":["alu"],"mnemonic":"MULW","summary":"MULW - Compute the 32-bit product and sign-extend it.","surface":"scalar","id":"PTO-SCALAR-MULW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MULW() => ScalarOperation
begin
    return ScalarOperation_MULW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MULW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyW;
end;
// DOC-END: operation
