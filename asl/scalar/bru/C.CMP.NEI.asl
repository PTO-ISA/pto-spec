// PTO-INSTRUCTION: {"assembly":["c.cmp.nei t#1, simm, ->t"],"block":[],"catalog_indices":[35],"catalog_records":[{"asm":"c.cmp.nei t#1, simm, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x082c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"simm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_cmp_nei_16_35d1f02063e2","length_bits":16,"mnemonic":"C.CMP.NEI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompare","status":"accepted"}],"classification":["bru"],"mnemonic":"C.CMP.NEI","summary":"Execute the C.CMP.NEI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-CMP-NEI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_CMP_NEI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_NEI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_CMP_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
// DOC-END: operation
