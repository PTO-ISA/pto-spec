// PTO-INSTRUCTION: {"assembly":["fdiv.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[103],"catalog_records":[{"asm":"fdiv.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000304b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fdiv_32_04a5bb6ab56f","length_bits":32,"mnemonic":"FDIV","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingBinary","status":"accepted"}],"classification":["fsu"],"mnemonic":"FDIV","summary":"Execute the FDIV scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-FDIV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FDIV() => ScalarOperation
begin
    return ScalarOperation_FDIV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FDIV() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;
// DOC-END: operation
