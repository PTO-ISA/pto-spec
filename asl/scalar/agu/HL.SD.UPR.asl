// PTO-INSTRUCTION: {"assembly":["hl.sd.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}"],"block":[],"catalog_indices":[256],"catalog_records":[{"asm":"hl.sd.upr SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff07ff","match":"0x00007049002e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"hl_sd_upr_48_af7118270a90","length_bits":48,"mnemonic":"HL.SD.UPR","semantic_family":"AGU","semantic_group":"STA/PRE_INDEX","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SD.UPR","summary":"Execute the HL.SD.UPR scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SD_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_SD_UPR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SD_UPR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
