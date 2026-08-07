// PTO-INSTRUCTION: {"assembly":["hl.ldi.u [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[171],"catalog_records":[{"asm":"hl.ldi.u [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00003029000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm22","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}],"signedness":"signed","width":22}],"form_id":"hl_ldi_u_48_894d02c12dcc","length_bits":48,"mnemonic":"HL.LDI.U","semantic_family":"AGU","semantic_group":"LDA/LONG","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.LDI.U","summary":"Execute the HL.LDI.U scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LDI_U() => ScalarOperation
begin
    return ScalarOperation_HL_LDI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LDI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
