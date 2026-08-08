// PTO-INSTRUCTION: {"assembly":["b.ne SrcL, SrcR, label"],"block":[],"catalog_indices":[17],"catalog_records":[{"asm":"b.ne SrcL, SrcR, label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001027","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}],"signedness":"signed","width":12}],"form_id":"b_ne_32_831af6a36ff4","length_bits":32,"mnemonic":"B.NE","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"BranchRelative","status":"accepted","semantic_summary":"B.NE - Conditionally branch to the PC-relative target after comparing scalar operands."}],"classification":["bru"],"mnemonic":"B.NE","summary":"B.NE - Conditionally branch to the PC-relative target after comparing scalar operands.","surface":"scalar","id":"PTO-SCALAR-B-NE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_B_NE() => ScalarOperation
begin
    return ScalarOperation_B_NE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_NE() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
// DOC-END: operation
