// PTO-INSTRUCTION: {"assembly":["lw.pcr [symbol], ->{t, u, Rd}"],"block":[],"catalog_indices":[352],"catalog_records":[{"asm":"lw.pcr [symbol], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002039","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"lw_pcr_32_d135a1aa4ffb","length_bits":32,"mnemonic":"LW.PCR","semantic_family":"AGU","semantic_group":"LDA","semantic_handler":"ExecuteScalarLoad","status":"accepted","semantic_summary":"LW.PCR - Load scalar data using this mnemonic's width, signedness, and address-update form."}],"classification":["agu"],"mnemonic":"LW.PCR","summary":"LW.PCR - Load scalar data using this mnemonic's width, signedness, and address-update form.","surface":"scalar","id":"PTO-SCALAR-LW-PCR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LW_PCR() => ScalarOperation
begin
    return ScalarOperation_LW_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LW_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
