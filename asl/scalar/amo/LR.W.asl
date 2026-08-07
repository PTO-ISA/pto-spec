// PTO-INSTRUCTION: {"assembly":["lr.w<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], {->t, ->u, ->Rd}"],"block":[],"catalog_indices":[345],"catalog_records":[{"asm":"lr.w<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> [SrcL], {->t, ->u, ->Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707f","match":"0x2000000b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcZero","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"lr_w_32_efecc735bb75","length_bits":32,"mnemonic":"LR.W","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"LoadReserved","status":"accepted"}],"classification":["amo"],"mnemonic":"LR.W","summary":"Execute the LR.W scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LR_W() => ScalarOperation
begin
    return ScalarOperation_LR_W;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LR_W() => ScalarSemanticHandler
begin
    return ScalarHandler_LoadReserved;
end;
// DOC-END: operation
