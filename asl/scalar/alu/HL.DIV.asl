// PTO-INSTRUCTION: {"assembly":["hl.div SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[145],"catalog_records":[{"asm":"hl.div SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00000057000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_div_48_e8ff1fc1cb98","length_bits":48,"mnemonic":"HL.DIV","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarDividePair","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.DIV","summary":"Execute the HL.DIV scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_DIV() => ScalarOperation
begin
    return ScalarOperation_HL_DIV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
// DOC-END: operation
