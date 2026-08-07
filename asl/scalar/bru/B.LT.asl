// PTO-INSTRUCTION: {"assembly":["b.lt SrcL, SrcR, label"],"block":[],"catalog_indices":[15],"catalog_records":[{"asm":"b.lt SrcL, SrcR, label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002027","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}],"signedness":"signed","width":12}],"form_id":"b_lt_32_2ca5ecd25cfb","length_bits":32,"mnemonic":"B.LT","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"BranchRelative","status":"accepted"}],"classification":["bru"],"mnemonic":"B.LT","summary":"Execute the B.LT scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_B_LT() => ScalarOperation
begin
    return ScalarOperation_B_LT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_LT() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
// DOC-END: operation
