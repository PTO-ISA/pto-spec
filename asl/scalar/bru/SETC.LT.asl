// PTO-INSTRUCTION: {"assembly":["setc.lt SrcL, SrcR<{.sw, .uw}>"],"block":[],"catalog_indices":[414],"catalog_records":[{"asm":"setc.lt SrcL, SrcR<{.sw, .uw}>","constraints":[],"encoding":[{"index":0,"mask":"0xf8007fff","match":"0x00004065","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"setc_lt_32_10de99f3ad6a","length_bits":32,"mnemonic":"SETC.LT","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted","semantic_summary":"SETC.LT - Compare scalar operands and update the bundle commit condition."}],"classification":["bru"],"mnemonic":"SETC.LT","summary":"SETC.LT - Compare scalar operands and update the bundle commit condition.","surface":"scalar","id":"PTO-SCALAR-SETC-LT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_LT() => ScalarOperation
begin
    return ScalarOperation_SETC_LT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_LT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
