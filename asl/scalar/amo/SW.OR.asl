// PTO-INSTRUCTION: {"assembly":["sw.or<.{rl, f, rlf}> [SrcL], SrcR"],"block":[],"catalog_indices":[451],"catalog_records":[{"asm":"sw.or<.{rl, f, rlf}> [SrcL], SrcR","constraints":[],"encoding":[{"index":0,"mask":"0xf4007fff","match":"0x2000300b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"sw_or_32_354579538c4e","length_bits":32,"mnemonic":"SW.OR","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","status":"accepted","semantic_summary":"SW.OR - Atomically read, apply this mnemonic's named operation, and write the scalar memory location."}],"classification":["amo"],"mnemonic":"SW.OR","summary":"SW.OR - Atomically read, apply this mnemonic's named operation, and write the scalar memory location.","surface":"scalar","id":"PTO-SCALAR-SW-OR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SW_OR() => ScalarOperation
begin
    return ScalarOperation_SW_OR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SW_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
// DOC-END: operation
