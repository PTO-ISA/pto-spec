// PTO-INSTRUCTION: {"assembly":["c.ldi [srcL, simm], ->t"],"block":[],"catalog_indices":[37],"catalog_records":[{"asm":"c.ldi [srcL, simm], ->t","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x001a","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_ldi_16_973f42d37f29","length_bits":16,"mnemonic":"C.LDI","semantic_family":"AGU","semantic_group":"LDA/BASE_IMM","semantic_handler":"ExecuteScalarLoad","status":"accepted","semantic_summary":"C.LDI - Load scalar data using this mnemonic's width, signedness, and address-update form."}],"classification":["agu"],"mnemonic":"C.LDI","summary":"C.LDI - Load scalar data using this mnemonic's width, signedness, and address-update form.","surface":"scalar","id":"PTO-SCALAR-C-LDI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_LDI() => ScalarOperation
begin
    return ScalarOperation_C_LDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_LDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
