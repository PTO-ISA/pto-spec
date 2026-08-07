// PTO-INSTRUCTION: {"assembly":["lw.umax<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}"],"block":[],"catalog_indices":[355],"catalog_records":[{"asm":"lw.umax<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], SrcR, {->t, ->u, ->Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707f","match":"0x6000200b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"lw_umax_32_3c6a5a534674","length_bits":32,"mnemonic":"LW.UMAX","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"AtomicReadModifyWrite","status":"accepted"}],"classification":["amo"],"mnemonic":"LW.UMAX","summary":"Execute the LW.UMAX scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LW_UMAX() => ScalarOperation
begin
    return ScalarOperation_LW_UMAX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LW_UMAX() => ScalarSemanticHandler
begin
    return ScalarHandler_AtomicReadModifyWrite;
end;
// DOC-END: operation
