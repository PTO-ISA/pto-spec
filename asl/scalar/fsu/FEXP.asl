// PTO-INSTRUCTION: {"assembly":["fexp.{T} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[108],"catalog_records":[{"asm":"fexp.{T} SrcL, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf9f0707f","match":"0x0000307b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fexp_32_592ef5288c7d","length_bits":32,"mnemonic":"FEXP","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingUnary","status":"accepted","semantic_summary":"FEXP - Compute this mnemonic's unary floating-point operation."}],"classification":["fsu"],"mnemonic":"FEXP","summary":"FEXP - Compute this mnemonic's unary floating-point operation.","surface":"scalar","id":"PTO-SCALAR-FEXP","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FEXP() => ScalarOperation
begin
    return ScalarOperation_FEXP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FEXP() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;
// DOC-END: operation
