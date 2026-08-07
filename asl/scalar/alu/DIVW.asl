// PTO-INSTRUCTION: {"assembly":["divw SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[93],"catalog_records":[{"asm":"divw SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00002057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"divw_32_b6366c50ac8c","length_bits":32,"mnemonic":"DIVW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarDivideSignedW","status":"accepted"}],"classification":["alu"],"mnemonic":"DIVW","summary":"Execute the DIVW scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DIVW() => ScalarOperation
begin
    return ScalarOperation_DIVW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSignedW;
end;
// DOC-END: operation
