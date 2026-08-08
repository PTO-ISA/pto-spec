// PTO-INSTRUCTION: {"assembly":["ssrget SSR_ID, ->{t, u, Rd}"],"block":[],"catalog_indices":[441],"catalog_records":[{"asm":"ssrget SSR_ID, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x000ff07f","match":"0x0000003b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SSR_ID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12}],"form_id":"ssrget_32_959957ab6b75","length_bits":32,"mnemonic":"SSRGET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterGet","status":"accepted"}],"classification":["sys"],"mnemonic":"SSRGET","summary":"Execute the SSRGET scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SSRGET","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SSRGET() => ScalarOperation
begin
    return ScalarOperation_SSRGET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;
// DOC-END: operation
