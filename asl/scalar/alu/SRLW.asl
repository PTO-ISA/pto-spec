// PTO-INSTRUCTION: {"assembly":["srlw SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[440],"catalog_records":[{"asm":"srlw SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00005025","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"srlw_32_2c6458b2aadb","length_bits":32,"mnemonic":"SRLW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","status":"accepted"}],"classification":["alu"],"mnemonic":"SRLW","summary":"Execute the SRLW scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SRLW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SRLW() => ScalarOperation
begin
    return ScalarOperation_SRLW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SRLW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
// DOC-END: operation
