// PTO-INSTRUCTION: {"assembly":["fges.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[110],"catalog_records":[{"asm":"fges.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0800305b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fges_32_e0301fcee743","length_bits":32,"mnemonic":"FGES","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingCompare","status":"accepted"}],"classification":["fsu"],"mnemonic":"FGES","summary":"Execute the FGES scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-FGES","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FGES() => ScalarOperation
begin
    return ScalarOperation_FGES;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FGES() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;
// DOC-END: operation
