// PTO-INSTRUCTION: {"assembly":["bic SrcL, M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[23],"catalog_records":[{"asm":"bic SrcL, M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002067","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imml","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"bic_32_3a10830a3a93","length_bits":32,"mnemonic":"BIC","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ModifyBitfield","status":"accepted"}],"classification":["alu"],"mnemonic":"BIC","summary":"Execute the BIC scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BIC() => ScalarOperation
begin
    return ScalarOperation_BIC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BIC() => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;
// DOC-END: operation
