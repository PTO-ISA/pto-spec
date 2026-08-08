// PTO-INSTRUCTION: {"assembly":["hl.cmp.lti SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[141],"catalog_records":[{"asm":"hl.cmp.lti SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00004055000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_cmp_lti_48_bec21b77021a","length_bits":48,"mnemonic":"HL.CMP.LTI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted"}],"classification":["bru"],"mnemonic":"HL.CMP.LTI","summary":"Execute the HL.CMP.LTI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-CMP-LTI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CMP_LTI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_LTI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CMP_LTI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
