// PTO-INSTRUCTION: {"assembly":["setc.eq SrcL, SrcR<{.sw, .uw}>"],"block":[],"catalog_indices":[408],"catalog_records":[{"asm":"setc.eq SrcL, SrcR<{.sw, .uw}>","constraints":[],"encoding":[{"index":0,"mask":"0xf8007fff","match":"0x00000065","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"setc_eq_32_fb06e1dddc5c","length_bits":32,"mnemonic":"SETC.EQ","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted"}],"classification":["bru"],"mnemonic":"SETC.EQ","summary":"Execute the SETC.EQ scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_EQ() => ScalarOperation
begin
    return ScalarOperation_SETC_EQ;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_EQ() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
