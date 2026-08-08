// PTO-INSTRUCTION: {"assembly":["slli SrcL, shamt, ->{t, u, Rd}"],"block":[],"catalog_indices":[430],"catalog_records":[{"asm":"slli SrcL, shamt, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfc00707f","match":"0x00007015","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"slli_32_b43ca2454e3a","length_bits":32,"mnemonic":"SLLI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted"}],"classification":["alu"],"mnemonic":"SLLI","summary":"Execute the SLLI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SLLI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SLLI() => ScalarOperation
begin
    return ScalarOperation_SLLI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SLLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
