// PTO-INSTRUCTION: {"assembly":["fmin.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[115],"catalog_records":[{"asm":"fmin.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0000705b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fmin_32_b5c106e5cd7e","length_bits":32,"mnemonic":"FMIN","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingBinary","status":"accepted"}],"classification":["fsu"],"mnemonic":"FMIN","summary":"Execute the FMIN scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FMIN() => ScalarOperation
begin
    return ScalarOperation_FMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FMIN() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingBinary;
end;
// DOC-END: operation
