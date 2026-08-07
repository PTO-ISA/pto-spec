// PTO-INSTRUCTION: {"assembly":["fmul.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[117],"catalog_records":[{"asm":"fmul.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000204b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fmul_32_7d521d9d65e7","length_bits":32,"mnemonic":"FMUL","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingBinary","status":"accepted"}],"classification":["fsu"],"mnemonic":"FMUL","summary":"Execute the FMUL scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FMUL() => ScalarOperation
begin
    return ScalarOperation_FMUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FMUL() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;
// DOC-END: operation
