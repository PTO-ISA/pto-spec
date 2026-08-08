// PTO-INSTRUCTION: {"assembly":["hl.cmp.geui SrcL, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[140],"catalog_records":[{"asm":"hl.cmp.geui SrcL, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00007055000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"unsigned","width":24}],"form_id":"hl_cmp_geui_48_c71f4fb29e6b","length_bits":48,"mnemonic":"HL.CMP.GEUI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted","semantic_summary":"HL.CMP.GEUI - Compare scalar operands and write the encoded boolean result."}],"classification":["bru"],"mnemonic":"HL.CMP.GEUI","summary":"HL.CMP.GEUI - Compare scalar operands and write the encoded boolean result.","surface":"scalar","id":"PTO-SCALAR-HL-CMP-GEUI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CMP_GEUI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_GEUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CMP_GEUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
