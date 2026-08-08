// PTO-INSTRUCTION: {"assembly":["lh.pcr [symbol], ->{t, u, Rd}"],"block":[],"catalog_indices":[335],"catalog_records":[{"asm":"lh.pcr [symbol], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001039","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17}],"signedness":"signed","width":17}],"form_id":"lh_pcr_32_aabf46d21e49","length_bits":32,"mnemonic":"LH.PCR","semantic_family":"AGU","semantic_group":"LDA","semantic_handler":"ExecuteScalarLoad","status":"accepted","semantic_summary":"LH.PCR - Load scalar data using this mnemonic's width, signedness, and address-update form."}],"classification":["agu"],"mnemonic":"LH.PCR","summary":"LH.PCR - Load scalar data using this mnemonic's width, signedness, and address-update form.","surface":"scalar","id":"PTO-SCALAR-LH-PCR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LH_PCR() => ScalarOperation
begin
    return ScalarOperation_LH_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LH_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
