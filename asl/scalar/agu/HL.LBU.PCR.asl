// PTO-INSTRUCTION: {"assembly":["hl.lbu.pcr [<symbol>], ->{t, u, Rd}"],"block":[],"catalog_indices":[157],"catalog_records":[{"asm":"hl.lbu.pcr [<symbol>], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00004039000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}],"signedness":"signed","width":29}],"form_id":"hl_lbu_pcr_48_504b34c0ec9d","length_bits":48,"mnemonic":"HL.LBU.PCR","semantic_family":"AGU","semantic_group":"LDA/PC_REL","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.LBU.PCR","summary":"Execute the HL.LBU.PCR scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-LBU-PCR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LBU_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LBU_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LBU_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
