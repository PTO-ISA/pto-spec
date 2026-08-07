// PTO-INSTRUCTION: {"assembly":["madd SrcL, SrcR, SrcD, ->{t, u, Rd}"],"block":[],"catalog_indices":[364],"catalog_records":[{"asm":"madd SrcL, SrcR, SrcD, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0600707f","match":"0x00006047","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"madd_32_6208e8e59303","length_bits":32,"mnemonic":"MADD","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarMultiplyAdd","status":"accepted"}],"classification":["alu"],"mnemonic":"MADD","summary":"Execute the MADD scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MADD() => ScalarOperation
begin
    return ScalarOperation_MADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAdd;
end;
// DOC-END: operation
