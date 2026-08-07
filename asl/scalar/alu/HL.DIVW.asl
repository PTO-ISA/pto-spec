// PTO-INSTRUCTION: {"assembly":["hl.divw SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[148],"catalog_records":[{"asm":"hl.divw SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00002057000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_divw_48_9048cdb3b22f","length_bits":48,"mnemonic":"HL.DIVW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarDividePairW","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.DIVW","summary":"Execute the HL.DIVW scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_DIVW() => ScalarOperation
begin
    return ScalarOperation_HL_DIVW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_DIVW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
// DOC-END: operation
