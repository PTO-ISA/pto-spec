// PTO-INSTRUCTION: {"assembly":["sd.umin<.{rl, f, rlf}> [SrcL], SrcR"],"block":[],"catalog_indices":[402],"catalog_records":[{"asm":"sd.umin<.{rl, f, rlf}> [SrcL], SrcR","constraints":[],"encoding":[{"index":0,"mask":"0xf4007fff","match":"0x7000500b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"sd_umin_32_2388cbb378ac","length_bits":32,"mnemonic":"SD.UMIN","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","status":"accepted"}],"classification":["amo"],"mnemonic":"SD.UMIN","summary":"Execute the SD.UMIN scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SD_UMIN() => ScalarOperation
begin
    return ScalarOperation_SD_UMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SD_UMIN() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
// DOC-END: operation
