// PTO-INSTRUCTION: {"assembly":["hl.divu SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[146],"catalog_records":[{"asm":"hl.divu SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00001057000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_divu_48_597acda29e08","length_bits":48,"mnemonic":"HL.DIVU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarDividePair","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.DIVU","summary":"Execute the HL.DIVU scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_DIVU() => ScalarOperation
begin
    return ScalarOperation_HL_DIVU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
// DOC-END: operation
