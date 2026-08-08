// PTO-INSTRUCTION: {"assembly":["hl.ssrset SrcL, SSR_ID"],"block":[],"catalog_indices":[292],"catalog_records":[{"asm":"hl.ssrset SrcL, SSR_ID","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff000f","match":"0x0000103b000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SSR_ID","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"encoding-defined","width":24},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_ssrset_48_dd25753307c2","length_bits":48,"mnemonic":"HL.SSRSET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterSet","status":"accepted","semantic_summary":"HL.SSRSET - Write the addressed system register."}],"classification":["sys"],"mnemonic":"HL.SSRSET","summary":"HL.SSRSET - Write the addressed system register.","surface":"scalar","id":"PTO-SCALAR-HL-SSRSET","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SSRSET() => ScalarOperation
begin
    return ScalarOperation_HL_SSRSET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SSRSET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSet;
end;
// DOC-END: operation
