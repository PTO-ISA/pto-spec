// PTO-INSTRUCTION: {"assembly":["sd.pcr SrcL, [symbol]"],"block":[],"catalog_indices":[397],"catalog_records":[{"asm":"sd.pcr SrcL, [symbol]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003069","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"sd_pcr_32_2340e0085413","length_bits":32,"mnemonic":"SD.PCR","semantic_family":"AGU","semantic_group":"STA","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SD.PCR","summary":"Execute the SD.PCR scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SD-PCR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SD_PCR() => ScalarOperation
begin
    return ScalarOperation_SD_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SD_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
