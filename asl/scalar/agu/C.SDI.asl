// PTO-INSTRUCTION: {"assembly":["c.sdi t#1, [srcL, simm]"],"block":[],"catalog_indices":[42],"catalog_records":[{"asm":"c.sdi t#1, [srcL, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x003a","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm5","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"signed","width":5}],"form_id":"c_sdi_16_bbec69bcfd5d","length_bits":16,"mnemonic":"C.SDI","semantic_family":"AGU","semantic_group":"STA/BASE_IMM","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"C.SDI","summary":"Execute the C.SDI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-SDI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SDI() => ScalarOperation
begin
    return ScalarOperation_C_SDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
