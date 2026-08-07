// PTO-INSTRUCTION: {"assembly":["ssrswap SrcL, SSR_ID, ->{t, u, Rd}"],"block":[],"catalog_indices":[443],"catalog_records":[{"asm":"ssrswap SrcL, SSR_ID, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x0000203b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SSR_ID","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"encoding-defined","width":12},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"ssrswap_32_a01c7e2c7c29","length_bits":32,"mnemonic":"SSRSWAP","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteSystemRegisterSwap","status":"accepted"}],"classification":["sys"],"mnemonic":"SSRSWAP","summary":"Execute the SSRSWAP scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SSRSWAP() => ScalarOperation
begin
    return ScalarOperation_SSRSWAP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SSRSWAP() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterSwap;
end;
// DOC-END: operation
