// PTO-INSTRUCTION: {"assembly":["casw<.{aq, rl, aqrl}> [SrcL], SrcR, SrcD, ->{t, u, Rd}"],"block":[],"catalog_indices":[61],"catalog_records":[{"asm":"casw<.{aq, rl, aqrl}> [SrcL], SrcR, SrcD, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x0000201b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"aq","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1},{"name":"rl","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":1}],"signedness":"encoding-defined","width":1}],"form_id":"casw_32_cb29e4287223","length_bits":32,"mnemonic":"CASW","semantic_family":"AMO","semantic_group":"AMO","semantic_handler":"CompareAndSwap","status":"accepted","semantic_summary":"CASW - Atomically compare the scalar memory value and conditionally store the replacement."}],"classification":["amo"],"mnemonic":"CASW","summary":"CASW - Atomically compare the scalar memory value and conditionally store the replacement.","surface":"scalar","id":"PTO-SCALAR-CASW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CASW() => ScalarOperation
begin
    return ScalarOperation_CASW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CASW() => ScalarSemanticHandler
begin
    return ScalarHandler_CompareAndSwap;
end;
// DOC-END: operation
