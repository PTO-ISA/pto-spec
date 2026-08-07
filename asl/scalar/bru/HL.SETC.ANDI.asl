// PTO-INSTRUCTION: {"assembly":["hl.setc.andi SrcL, simm"],"block":[],"catalog_indices":[267],"catalog_records":[{"asm":"hl.setc.andi SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00002075000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_setc_andi_48_f27796612fb3","length_bits":48,"mnemonic":"HL.SETC.ANDI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"HL.SETC.ANDI","summary":"Execute the HL.SETC.ANDI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SETC_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_ANDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SETC_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;
// DOC-END: operation
