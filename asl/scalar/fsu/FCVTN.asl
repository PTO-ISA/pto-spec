// PTO-INSTRUCTION: {"assembly":["fcvtn.{srcT2dstT} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[100],"catalog_records":[{"asm":"fcvtn.{srcT2dstT} SrcL, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x01f0707f","match":"0x0000306b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DstType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fcvtn_32_8714ba358d80","length_bits":32,"mnemonic":"FCVTN","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"ConvertFloatingEncoding","status":"accepted"}],"classification":["fsu"],"mnemonic":"FCVTN","summary":"Execute the FCVTN scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FCVTN() => ScalarOperation
begin
    return ScalarOperation_FCVTN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FCVTN() => ScalarSemanticHandler
begin
    return ScalarHandler_ConvertFloatingEncoding;
end;
// DOC-END: operation
