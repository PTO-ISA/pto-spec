// PTO-INSTRUCTION: {"assembly":["hl.ssrget SSR_ID, ->{t, u, Rd}"],"block":[],"catalog_indices":[291],"catalog_records":[{"asm":"hl.ssrget SSR_ID, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x000ff07f000f","match":"0x0000003b000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SSR_ID","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"encoding-defined","width":24}],"form_id":"hl_ssrget_48_fde37e58a3c4","length_bits":48,"mnemonic":"HL.SSRGET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterGet","status":"accepted"}],"classification":["sys"],"mnemonic":"HL.SSRGET","summary":"Execute the HL.SSRGET scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SSRGET() => ScalarOperation
begin
    return ScalarOperation_HL_SSRGET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;
// DOC-END: operation
