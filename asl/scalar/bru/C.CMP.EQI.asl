// PTO-INSTRUCTION: {"assembly":["c.cmp.eqi t#1, simm, ->t"],"block":[],"catalog_indices":[34],"catalog_records":[{"asm":"c.cmp.eqi t#1, simm, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x002c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"simm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_cmp_eqi_16_e34367883ba1","length_bits":16,"mnemonic":"C.CMP.EQI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted"}],"classification":["bru"],"mnemonic":"C.CMP.EQI","summary":"Execute the C.CMP.EQI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_CMP_EQI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_EQI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_CMP_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
