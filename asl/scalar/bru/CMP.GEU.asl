// PTO-INSTRUCTION: {"assembly":["cmp.geu SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}"],"block":[],"catalog_indices":[69],"catalog_records":[{"asm":"cmp.geu SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x00007045","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"cmp_geu_32_0c002dc415ef","length_bits":32,"mnemonic":"CMP.GEU","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted"}],"classification":["bru"],"mnemonic":"CMP.GEU","summary":"Execute the CMP.GEU scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_GEU() => ScalarOperation
begin
    return ScalarOperation_CMP_GEU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_GEU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
