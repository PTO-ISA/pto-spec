// PTO-INSTRUCTION: {"assembly":["setc.ltui SrcL, uimm"],"block":[],"catalog_indices":[417],"catalog_records":[{"asm":"setc.ltui SrcL, uimm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00006075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"unsigned","width":12}],"form_id":"setc_ltui_32_7908d25901c6","length_bits":32,"mnemonic":"SETC.LTUI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted","semantic_summary":"SETC.LTUI - Compare scalar operands and update the bundle commit condition."}],"classification":["bru"],"mnemonic":"SETC.LTUI","summary":"SETC.LTUI - Compare scalar operands and update the bundle commit condition.","surface":"scalar","id":"PTO-SCALAR-SETC-LTUI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_LTUI() => ScalarOperation
begin
    return ScalarOperation_SETC_LTUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
