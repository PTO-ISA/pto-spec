// PTO-INSTRUCTION: {"assembly":["setc.geui SrcL, uimm"],"block":[],"catalog_indices":[413],"catalog_records":[{"asm":"setc.geui SrcL, uimm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00007075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"unsigned","width":12}],"form_id":"setc_geui_32_6c34bc4ad314","length_bits":32,"mnemonic":"SETC.GEUI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted"}],"classification":["bru"],"mnemonic":"SETC.GEUI","summary":"Execute the SETC.GEUI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_GEUI() => ScalarOperation
begin
    return ScalarOperation_SETC_GEUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_GEUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
