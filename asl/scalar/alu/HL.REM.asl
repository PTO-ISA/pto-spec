// PTO-INSTRUCTION: {"assembly":["hl.rem SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[240],"catalog_records":[{"asm":"hl.rem SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00004057000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_rem_48_3c13e08615aa","length_bits":48,"mnemonic":"HL.REM","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarDividePair","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.REM","summary":"Execute the HL.REM scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_REM() => ScalarOperation
begin
    return ScalarOperation_HL_REM;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePair;
end;
// DOC-END: operation
