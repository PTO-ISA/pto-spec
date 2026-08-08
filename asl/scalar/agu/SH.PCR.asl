// PTO-INSTRUCTION: {"assembly":["sh.pcr SrcL, [symbol]"],"block":[],"catalog_indices":[425],"catalog_records":[{"asm":"sh.pcr SrcL, [symbol]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001069","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"sh_pcr_32_14ba505eb3c2","length_bits":32,"mnemonic":"SH.PCR","semantic_family":"AGU","semantic_group":"STA","semantic_handler":"ExecuteScalarStore","status":"accepted","semantic_summary":"SH.PCR - Store scalar data using this mnemonic's width and address-update form."}],"classification":["agu"],"mnemonic":"SH.PCR","summary":"SH.PCR - Store scalar data using this mnemonic's width and address-update form.","surface":"scalar","id":"PTO-SCALAR-SH-PCR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SH_PCR() => ScalarOperation
begin
    return ScalarOperation_SH_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SH_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
