// PTO-INSTRUCTION: {"assembly":["sd.xor<.{rl, f, rlf}> [SrcL], SrcR"],"block":[],"catalog_indices":[403],"catalog_records":[{"asm":"sd.xor<.{rl, f, rlf}> [SrcL], SrcR","constraints":[],"encoding":[{"index":0,"mask":"0xf4007fff","match":"0x3000500b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"sd_xor_32_7655ceaf9497","length_bits":32,"mnemonic":"SD.XOR","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","status":"accepted","semantic_summary":"SD.XOR - Atomically read, apply this mnemonic's named operation, and write the scalar memory location."}],"classification":["amo"],"mnemonic":"SD.XOR","summary":"SD.XOR - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.","surface":"scalar","id":"PTO-SCALAR-SD-XOR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SD_XOR() => ScalarOperation
begin
    return ScalarOperation_SD_XOR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SD_XOR() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
// DOC-END: operation
