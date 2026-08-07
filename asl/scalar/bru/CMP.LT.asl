// PTO-INSTRUCTION: {"assembly":["cmp.lt SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}"],"block":[],"catalog_indices":[71],"catalog_records":[{"asm":"cmp.lt SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x00004045","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"cmp_lt_32_c0b8cc320f12","length_bits":32,"mnemonic":"CMP.LT","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted"}],"classification":["bru"],"mnemonic":"CMP.LT","summary":"Execute the CMP.LT scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_LT() => ScalarOperation
begin
    return ScalarOperation_CMP_LT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_LT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
