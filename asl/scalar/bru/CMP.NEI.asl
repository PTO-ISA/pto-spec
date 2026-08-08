// PTO-INSTRUCTION: {"assembly":["cmp.nei SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[76],"catalog_records":[{"asm":"cmp.nei SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001055","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"cmp_nei_32_00abf831b572","length_bits":32,"mnemonic":"CMP.NEI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted","semantic_summary":"CMP.NEI - Compare scalar operands and write the encoded boolean result."}],"classification":["bru"],"mnemonic":"CMP.NEI","summary":"CMP.NEI - Compare scalar operands and write the encoded boolean result.","surface":"scalar","id":"PTO-SCALAR-CMP-NEI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_NEI() => ScalarOperation
begin
    return ScalarOperation_CMP_NEI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
