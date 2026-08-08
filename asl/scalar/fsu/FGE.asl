// PTO-INSTRUCTION: {"assembly":["fge.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[109],"catalog_records":[{"asm":"fge.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000305b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fge_32_b3244b2ffa89","length_bits":32,"mnemonic":"FGE","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingCompare","status":"accepted"}],"classification":["fsu"],"mnemonic":"FGE","summary":"Execute the FGE scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-FGE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FGE() => ScalarOperation
begin
    return ScalarOperation_FGE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FGE() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;
// DOC-END: operation
