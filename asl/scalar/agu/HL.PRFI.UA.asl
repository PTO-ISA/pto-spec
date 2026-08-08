// PTO-INSTRUCTION: {"assembly":["hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[239],"catalog_records":[{"asm":"hl.prfi.ua{.l1,.l2,.l3} [SrcL, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00007029001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"model","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_prfi_ua_48_c37fb30ecb0f","length_bits":48,"mnemonic":"HL.PRFI.UA","semantic_family":"AGU","semantic_group":"LDA","semantic_handler":"ScalarPrefetch","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.PRFI.UA","summary":"Execute the HL.PRFI.UA scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-PRFI-UA","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_PRFI_UA() => ScalarOperation
begin
    return ScalarOperation_HL_PRFI_UA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_PRFI_UA() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
// DOC-END: operation
