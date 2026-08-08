// PTO-INSTRUCTION: {"assembly":["muluw SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[372],"catalog_records":[{"asm":"muluw SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00003047","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"muluw_32_8f52b3d45e53","length_bits":32,"mnemonic":"MULUW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarMultiplyW","status":"accepted","semantic_summary":"MULUW - Compute the 32-bit product and sign-extend it."}],"classification":["alu"],"mnemonic":"MULUW","summary":"MULUW - Compute the 32-bit product and sign-extend it.","surface":"scalar","id":"PTO-SCALAR-MULUW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MULUW() => ScalarOperation
begin
    return ScalarOperation_MULUW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MULUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyW;
end;
// DOC-END: operation
