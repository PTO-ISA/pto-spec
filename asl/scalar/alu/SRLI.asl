// PTO-INSTRUCTION: {"assembly":["srli SrcL, shamt, ->{t, u, Rd}"],"block":[],"catalog_indices":[438],"catalog_records":[{"asm":"srli SrcL, shamt, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfc00707f","match":"0x00005015","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"srli_32_dd29ca058cfe","length_bits":32,"mnemonic":"SRLI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted"}],"classification":["alu"],"mnemonic":"SRLI","summary":"Execute the SRLI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SRLI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SRLI() => ScalarOperation
begin
    return ScalarOperation_SRLI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SRLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
