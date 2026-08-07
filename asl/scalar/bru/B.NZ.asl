// PTO-INSTRUCTION: {"assembly":["b.nz label"],"block":[],"catalog_indices":[18],"catalog_records":[{"asm":"b.nz label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002037","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm22","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}],"signedness":"signed","width":22}],"form_id":"b_nz_32_0f583cdd8d4d","length_bits":32,"mnemonic":"B.NZ","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"BranchRelative","status":"accepted"}],"classification":["bru"],"mnemonic":"B.NZ","summary":"Execute the B.NZ scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_B_NZ() => ScalarOperation
begin
    return ScalarOperation_B_NZ;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_NZ() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
// DOC-END: operation
