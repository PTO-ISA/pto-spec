// PTO-INSTRUCTION: {"assembly":["hl.lwui.po [SrcL, simm], ->Dst0, Dst1"],"block":[],"catalog_indices":[220],"catalog_records":[{"asm":"hl.lwui.po [SrcL, simm], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00006019003e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_lwui_po_48_09a75b628dc4","length_bits":48,"mnemonic":"HL.LWUI.PO","semantic_family":"AGU","semantic_group":"LDA/POST_INDEX","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.LWUI.PO","summary":"Execute the HL.LWUI.PO scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-LWUI-PO","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LWUI_PO() => ScalarOperation
begin
    return ScalarOperation_HL_LWUI_PO;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LWUI_PO() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
