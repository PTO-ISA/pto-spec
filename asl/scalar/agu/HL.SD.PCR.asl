// PTO-INSTRUCTION: {"assembly":["hl.sd.pcr SrcL, [<symbol>]"],"block":[],"catalog_indices":[252],"catalog_records":[{"asm":"hl.sd.pcr SrcL, [<symbol>]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00003069000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":23,"value_lsb":12,"width":5},{"instruction_lsb":4,"value_lsb":17,"width":12}],"signedness":"signed","width":29}],"form_id":"hl_sd_pcr_48_8ed6bb942a78","length_bits":48,"mnemonic":"HL.SD.PCR","semantic_family":"AGU","semantic_group":"STA/PC_REL","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SD.PCR","summary":"Execute the HL.SD.PCR scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SD_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_SD_PCR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SD_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
