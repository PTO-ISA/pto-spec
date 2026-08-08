// PTO-INSTRUCTION: {"assembly":["sraiw SrcL, shamt, ->{t, u, Rd}"],"block":[],"catalog_indices":[435],"catalog_records":[{"asm":"sraiw SrcL, shamt, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00006035","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"sraiw_32_db04a6299504","length_bits":32,"mnemonic":"SRAIW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","status":"accepted"}],"classification":["alu"],"mnemonic":"SRAIW","summary":"Execute the SRAIW scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SRAIW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SRAIW() => ScalarOperation
begin
    return ScalarOperation_SRAIW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SRAIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
// DOC-END: operation
