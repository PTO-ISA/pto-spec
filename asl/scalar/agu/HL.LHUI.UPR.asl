// PTO-INSTRUCTION: {"assembly":["hl.lhui.upr [SrcL, simm], ->Dst0, Dst1"],"block":[],"catalog_indices":[197],"catalog_records":[{"asm":"hl.lhui.upr [SrcL, simm], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00005029002e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_lhui_upr_48_7e66aaf61701","length_bits":48,"mnemonic":"HL.LHUI.UPR","semantic_family":"AGU","semantic_group":"LDA/PRE_INDEX","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.LHUI.UPR","summary":"Execute the HL.LHUI.UPR scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LHUI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_LHUI_UPR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LHUI_UPR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
