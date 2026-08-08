// PTO-INSTRUCTION: {"assembly":["cmp.eqi SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[66],"catalog_records":[{"asm":"cmp.eqi SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000055","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"cmp_eqi_32_252943516dca","length_bits":32,"mnemonic":"CMP.EQI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted","semantic_summary":"CMP.EQI - Compare scalar operands and write the encoded boolean result."}],"classification":["bru"],"mnemonic":"CMP.EQI","summary":"CMP.EQI - Compare scalar operands and write the encoded boolean result.","surface":"scalar","id":"PTO-SCALAR-CMP-EQI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_EQI() => ScalarOperation
begin
    return ScalarOperation_CMP_EQI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
