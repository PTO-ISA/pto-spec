// PTO-INSTRUCTION: {"assembly":["divuw SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[92],"catalog_records":[{"asm":"divuw SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00003057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"divuw_32_9c9470ef8982","length_bits":32,"mnemonic":"DIVUW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarDivideUnsignedW","status":"accepted","semantic_summary":"DIVUW - Compute unsigned 32-bit quotient and sign-extend it."}],"classification":["alu"],"mnemonic":"DIVUW","summary":"DIVUW - Compute unsigned 32-bit quotient and sign-extend it.","surface":"scalar","id":"PTO-SCALAR-DIVUW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DIVUW() => ScalarOperation
begin
    return ScalarOperation_DIVUW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DIVUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideUnsignedW;
end;
// DOC-END: operation
