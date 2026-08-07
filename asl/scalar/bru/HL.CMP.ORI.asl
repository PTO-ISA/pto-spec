// PTO-INSTRUCTION: {"assembly":["hl.cmp.ori SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[144],"catalog_records":[{"asm":"hl.cmp.ori SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00003055000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_cmp_ori_48_4167568cb50b","length_bits":48,"mnemonic":"HL.CMP.ORI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompareLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"HL.CMP.ORI","summary":"Execute the HL.CMP.ORI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CMP_ORI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_ORI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CMP_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
// DOC-END: operation
