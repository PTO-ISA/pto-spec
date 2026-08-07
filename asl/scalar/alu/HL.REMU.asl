// PTO-INSTRUCTION: {"assembly":["hl.remu SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[241],"catalog_records":[{"asm":"hl.remu SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00005057000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_remu_48_3bf4e5a663c1","length_bits":48,"mnemonic":"HL.REMU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarDividePair","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.REMU","summary":"Execute the HL.REMU scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_REMU() => ScalarOperation
begin
    return ScalarOperation_HL_REMU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
// DOC-END: operation
