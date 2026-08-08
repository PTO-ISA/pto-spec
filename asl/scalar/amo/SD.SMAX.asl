// PTO-INSTRUCTION: {"assembly":["sd.smax<.{rl, f, rlf}> [SrcL], SrcR"],"block":[],"catalog_indices":[398],"catalog_records":[{"asm":"sd.smax<.{rl, f, rlf}> [SrcL], SrcR","constraints":[],"encoding":[{"index":0,"mask":"0xf4007fff","match":"0x4000500b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"sd_smax_32_e59bf90b50c3","length_bits":32,"mnemonic":"SD.SMAX","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","status":"accepted","semantic_summary":"SD.SMAX - Atomically read, apply this mnemonic's named operation, and write the scalar memory location."}],"classification":["amo"],"mnemonic":"SD.SMAX","summary":"SD.SMAX - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.","surface":"scalar","id":"PTO-SCALAR-SD-SMAX","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SD_SMAX() => ScalarOperation
begin
    return ScalarOperation_SD_SMAX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SD_SMAX() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
// DOC-END: operation
