// PTO-INSTRUCTION: {"assembly":["hl.casd<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, SrcD, ->{t, u, Rd}"],"block":[],"catalog_indices":[132],"catalog_records":[{"asm":"hl.casd<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, SrcD, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707ff83f","match":"0x3000600b000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":42,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"hl_casd_48_fbb5c4256d30","length_bits":48,"mnemonic":"HL.CASD","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"CompareAndSwap","status":"accepted","semantic_summary":"HL.CASD - Atomically compare the scalar memory value and conditionally store the replacement."}],"classification":["amo"],"mnemonic":"HL.CASD","summary":"HL.CASD - Atomically compare the scalar memory value and conditionally store the replacement.","surface":"scalar","id":"PTO-SCALAR-HL-CASD","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CASD() => ScalarOperation
begin
    return ScalarOperation_HL_CASD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CASD() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;
// DOC-END: operation
