// PTO-INSTRUCTION: {"assembly":["maxu SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[367],"catalog_records":[{"asm":"maxu SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x0800405b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"maxu_32_b8789571339d","length_bits":32,"mnemonic":"MAXU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted","semantic_summary":"MAXU - Compute this mnemonic's binary scalar operation and write the selected destination."}],"classification":["alu"],"mnemonic":"MAXU","summary":"MAXU - Compute this mnemonic's binary scalar operation and write the selected destination.","surface":"scalar","id":"PTO-SCALAR-MAXU","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MAXU() => ScalarOperation
begin
    return ScalarOperation_MAXU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MAXU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
