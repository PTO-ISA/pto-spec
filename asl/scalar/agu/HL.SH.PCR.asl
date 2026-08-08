// PTO-INSTRUCTION: {"assembly":["hl.sh.pcr SrcL, [<symbol>]"],"block":[],"catalog_indices":[276],"catalog_records":[{"asm":"hl.sh.pcr SrcL, [<symbol>]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00001069000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":23,"value_lsb":12,"width":5},{"instruction_lsb":4,"value_lsb":17,"width":12}],"signedness":"signed","width":29}],"form_id":"hl_sh_pcr_48_705ea4062d0b","length_bits":48,"mnemonic":"HL.SH.PCR","semantic_family":"AGU","semantic_group":"STA/PC_REL","semantic_handler":"ExecuteScalarStore","status":"accepted","semantic_summary":"HL.SH.PCR - Store scalar data using this mnemonic's width and address-update form."}],"classification":["agu"],"mnemonic":"HL.SH.PCR","summary":"HL.SH.PCR - Store scalar data using this mnemonic's width and address-update form.","surface":"scalar","id":"PTO-SCALAR-HL-SH-PCR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SH_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SH_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SH_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
