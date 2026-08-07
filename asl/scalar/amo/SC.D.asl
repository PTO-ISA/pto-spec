// PTO-INSTRUCTION: {"assembly":["sc.d<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> SrcL, [SrcR], {->t, ->u, ->Rd}"],"block":[],"catalog_indices":[389],"catalog_records":[{"asm":"sc.d<.{aq, rl, f, aqrl, aqf, rlf, aqrlf}> SrcL, [SrcR], {->t, ->u, ->Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf000707f","match":"0x3000100b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"far","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"sc_d_32_2e714149031c","length_bits":32,"mnemonic":"SC.D","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"StoreConditional","status":"accepted"}],"classification":["amo"],"mnemonic":"SC.D","summary":"Execute the SC.D scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SC_D() => ScalarOperation
begin
    return ScalarOperation_SC_D;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SC_D() => ScalarSemanticHandler
begin
    return ScalarHandler_StoreConditional;
end;
// DOC-END: operation
