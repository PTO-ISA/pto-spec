// PTO-INSTRUCTION: {"assembly":["setc.ltu SrcL, SrcR<{.sw, .uw}>"],"block":[],"catalog_indices":[416],"catalog_records":[{"asm":"setc.ltu SrcL, SrcR<{.sw, .uw}>","constraints":[],"encoding":[{"index":0,"mask":"0xf8007fff","match":"0x00006065","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"setc_ltu_32_4a1ff65ecafb","length_bits":32,"mnemonic":"SETC.LTU","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted","semantic_summary":"SETC.LTU - Compare scalar operands and update the bundle commit condition."}],"classification":["bru"],"mnemonic":"SETC.LTU","summary":"SETC.LTU - Compare scalar operands and update the bundle commit condition.","surface":"scalar","id":"PTO-SCALAR-SETC-LTU","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_LTU() => ScalarOperation
begin
    return ScalarOperation_SETC_LTU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_LTU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
