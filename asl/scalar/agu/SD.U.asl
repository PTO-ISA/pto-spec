// PTO-INSTRUCTION: {"assembly":["sd.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]"],"block":[],"catalog_indices":[400],"catalog_records":[{"asm":"sd.u SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00007049","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"sd_u_32_1602c58c2031","length_bits":32,"mnemonic":"SD.U","semantic_family":"AGU","semantic_group":"STA/BASE_REG","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SD.U","summary":"Execute the SD.U scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SD_U() => ScalarOperation
begin
    return ScalarOperation_SD_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SD_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
