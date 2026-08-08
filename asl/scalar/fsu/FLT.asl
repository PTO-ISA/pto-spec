// PTO-INSTRUCTION: {"assembly":["flt.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[111],"catalog_records":[{"asm":"flt.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000205b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"flt_32_1c09549d8d3f","length_bits":32,"mnemonic":"FLT","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingCompare","status":"accepted"}],"classification":["fsu"],"mnemonic":"FLT","summary":"Execute the FLT scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-FLT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FLT() => ScalarOperation
begin
    return ScalarOperation_FLT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FLT() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;
// DOC-END: operation
