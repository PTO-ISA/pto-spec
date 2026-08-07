// PTO-INSTRUCTION: {"assembly":["divu SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[91],"catalog_records":[{"asm":"divu SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00001057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"divu_32_cfbc0d1760e4","length_bits":32,"mnemonic":"DIVU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarDivideUnsigned","status":"accepted"}],"classification":["alu"],"mnemonic":"DIVU","summary":"Execute the DIVU scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DIVU() => ScalarOperation
begin
    return ScalarOperation_DIVU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideUnsigned;
end;
// DOC-END: operation
