// PTO-INSTRUCTION: {"assembly":["cmp.ltui SrcL, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[74],"catalog_records":[{"asm":"cmp.ltui SrcL, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00006055","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"unsigned","width":12}],"form_id":"cmp_ltui_32_8676c7bfd797","length_bits":32,"mnemonic":"CMP.LTUI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted","semantic_summary":"CMP.LTUI - Compare scalar operands and write the encoded boolean result."}],"classification":["bru"],"mnemonic":"CMP.LTUI","summary":"CMP.LTUI - Compare scalar operands and write the encoded boolean result.","surface":"scalar","id":"PTO-SCALAR-CMP-LTUI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_LTUI() => ScalarOperation
begin
    return ScalarOperation_CMP_LTUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
