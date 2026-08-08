// PTO-INSTRUCTION: {"assembly":["ldi [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[332],"catalog_records":[{"asm":"ldi [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003019","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"ldi_32_d82a643f7a2b","length_bits":32,"mnemonic":"LDI","semantic_family":"AGU","semantic_group":"LDA/BASE_IMM","semantic_handler":"ExecuteScalarLoad","status":"accepted","semantic_summary":"LDI - Load scalar data using this mnemonic's width, signedness, and address-update form."}],"classification":["agu"],"mnemonic":"LDI","summary":"LDI - Load scalar data using this mnemonic's width, signedness, and address-update form.","surface":"scalar","id":"PTO-SCALAR-LDI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LDI() => ScalarOperation
begin
    return ScalarOperation_LDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
