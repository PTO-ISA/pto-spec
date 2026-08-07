// PTO-INSTRUCTION: {"assembly":["lb.pcr [symbol], ->{t, u, Rd}"],"block":[],"catalog_indices":[317],"catalog_records":[{"asm":"lb.pcr [symbol], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000039","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"lb_pcr_32_3fa2540b22d0","length_bits":32,"mnemonic":"LB.PCR","semantic_family":"AGU","semantic_group":"LDA","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"LB.PCR","summary":"Execute the LB.PCR scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LB_PCR() => ScalarOperation
begin
    return ScalarOperation_LB_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LB_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
