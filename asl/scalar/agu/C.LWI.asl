// PTO-INSTRUCTION: {"assembly":["c.lwi [srcL, simm], ->t"],"block":[],"catalog_indices":[38],"catalog_records":[{"asm":"c.lwi [srcL, simm], ->t","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x000a","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_lwi_16_b224525971da","length_bits":16,"mnemonic":"C.LWI","semantic_family":"AGU","semantic_group":"LDA/BASE_IMM","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"C.LWI","summary":"Execute the C.LWI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-LWI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_LWI() => ScalarOperation
begin
    return ScalarOperation_C_LWI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_LWI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
