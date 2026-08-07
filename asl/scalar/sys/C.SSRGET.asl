// PTO-INSTRUCTION: {"assembly":["c.ssrget SSR-ID, ->t"],"block":[],"catalog_indices":[52],"catalog_records":[{"asm":"c.ssrget SSR-ID, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x802c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SSRID","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_ssrget_16_9d83a6f2749a","length_bits":16,"mnemonic":"C.SSRGET","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteCompressedSystemRegisterGet","status":"accepted"}],"classification":["sys"],"mnemonic":"C.SSRGET","summary":"Execute the C.SSRGET scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SSRGET() => ScalarOperation
begin
    return ScalarOperation_C_SSRGET;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompressedSystemRegisterGet;
end;
// DOC-END: operation
