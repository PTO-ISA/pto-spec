// PTO-INSTRUCTION: {"assembly":["hl.cmp.andi SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[137],"catalog_records":[{"asm":"hl.cmp.andi SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00002055000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_cmp_andi_48_de2aae3f4516","length_bits":48,"mnemonic":"HL.CMP.ANDI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompareLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"HL.CMP.ANDI","summary":"Execute the HL.CMP.ANDI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-CMP-ANDI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CMP_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_ANDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CMP_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
// DOC-END: operation
