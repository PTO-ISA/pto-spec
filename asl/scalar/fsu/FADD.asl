// PTO-INSTRUCTION: {"assembly":["fadd.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[96],"catalog_records":[{"asm":"fadd.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000004b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fadd_32_b78b658e6740","length_bits":32,"mnemonic":"FADD","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingBinary","status":"accepted"}],"classification":["fsu"],"mnemonic":"FADD","summary":"Execute the FADD scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FADD() => ScalarOperation
begin
    return ScalarOperation_FADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FADD() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;
// DOC-END: operation
