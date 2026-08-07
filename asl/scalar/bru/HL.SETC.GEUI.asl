// PTO-INSTRUCTION: {"assembly":["hl.setc.geui SrcL, uimm"],"block":[],"catalog_indices":[270],"catalog_records":[{"asm":"hl.setc.geui SrcL, uimm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00007075000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"unsigned","width":24}],"form_id":"hl_setc_geui_48_2390319baf54","length_bits":48,"mnemonic":"HL.SETC.GEUI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted"}],"classification":["bru"],"mnemonic":"HL.SETC.GEUI","summary":"Execute the HL.SETC.GEUI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SETC_GEUI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_GEUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SETC_GEUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
