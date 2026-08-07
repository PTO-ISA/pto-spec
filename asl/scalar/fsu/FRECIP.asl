// PTO-INSTRUCTION: {"assembly":["frecip.{T} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[122],"catalog_records":[{"asm":"frecip.{T} SrcL, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf9f0707f","match":"0x0000207b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"frecip_32_3d51f4f727ea","length_bits":32,"mnemonic":"FRECIP","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingUnary","status":"accepted"}],"classification":["fsu"],"mnemonic":"FRECIP","summary":"Execute the FRECIP scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FRECIP() => ScalarOperation
begin
    return ScalarOperation_FRECIP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FRECIP() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;
// DOC-END: operation
