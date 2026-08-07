// PTO-INSTRUCTION: {"assembly":["hl.swi.u SrcD, [SrcR, simm]"],"block":[],"catalog_indices":[303],"catalog_records":[{"asm":"hl.swi.u SrcD, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00006059000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm22","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":10}],"signedness":"signed","width":22}],"form_id":"hl_swi_u_48_fac636330fd6","length_bits":48,"mnemonic":"HL.SWI.U","semantic_family":"AGU","semantic_group":"STA/LONG","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SWI.U","summary":"Execute the HL.SWI.U scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SWI_U() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SWI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
