// PTO-INSTRUCTION: {"assembly":["hl.lhi [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[180],"catalog_records":[{"asm":"hl.lhi [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00001019000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm22","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":10}],"signedness":"signed","width":22}],"form_id":"hl_lhi_48_6d94cb04aeac","length_bits":48,"mnemonic":"HL.LHI","semantic_family":"AGU","semantic_group":"LDA/LONG","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.LHI","summary":"Execute the HL.LHI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-LHI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LHI() => ScalarOperation
begin
    return ScalarOperation_HL_LHI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LHI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
