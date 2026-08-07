// PTO-INSTRUCTION: {"assembly":["cmp.or SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}"],"block":[],"catalog_indices":[77],"catalog_records":[{"asm":"cmp.or SrcL, SrcR<.sw, .uw, .not>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x00003045","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"cmp_or_32_75e1fa54ba94","length_bits":32,"mnemonic":"CMP.OR","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompareLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"CMP.OR","summary":"Execute the CMP.OR scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_OR() => ScalarOperation
begin
    return ScalarOperation_CMP_OR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
// DOC-END: operation
