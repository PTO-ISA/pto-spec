// PTO-INSTRUCTION: {"assembly":["hl.misub SrcL, SrcR, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[231],"catalog_records":[{"asm":"hl.misub SrcL, SrcR, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x0000104d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm19","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":4,"value_lsb":7,"width":12}],"signedness":"unsigned","width":19}],"form_id":"hl_misub_48_e9e4c7b23479","length_bits":48,"mnemonic":"HL.MISUB","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarMultiplyImmediateAdd","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.MISUB","summary":"Execute the HL.MISUB scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-MISUB","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_MISUB() => ScalarOperation
begin
    return ScalarOperation_HL_MISUB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_MISUB() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyImmediateAdd;
end;
// DOC-END: operation
