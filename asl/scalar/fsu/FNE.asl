// PTO-INSTRUCTION: {"assembly":["fne.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[118],"catalog_records":[{"asm":"fne.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000105b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fne_32_822c18caca3b","length_bits":32,"mnemonic":"FNE","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingCompare","status":"accepted","semantic_summary":"FNE - Compare floating-point operands and produce the encoded result."}],"classification":["fsu"],"mnemonic":"FNE","summary":"FNE - Compare floating-point operands and produce the encoded result.","surface":"scalar","id":"PTO-SCALAR-FNE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FNE() => ScalarOperation
begin
    return ScalarOperation_FNE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FNE() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;
// DOC-END: operation
