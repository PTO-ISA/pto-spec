// PTO-INSTRUCTION: {"assembly":["hl.cmp.gei SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[139],"catalog_records":[{"asm":"hl.cmp.gei SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00005055000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_cmp_gei_48_b3703d4c4619","length_bits":48,"mnemonic":"HL.CMP.GEI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted"}],"classification":["bru"],"mnemonic":"HL.CMP.GEI","summary":"Execute the HL.CMP.GEI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CMP_GEI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_GEI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CMP_GEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
