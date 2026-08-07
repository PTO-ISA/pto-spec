// PTO-INSTRUCTION: {"assembly":["fnes.{T} SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[119],"catalog_records":[{"asm":"fnes.{T} SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf800707f","match":"0x0800105b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fnes_32_9b4b5a493783","length_bits":32,"mnemonic":"FNES","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingCompare","status":"accepted"}],"classification":["fsu"],"mnemonic":"FNES","summary":"Execute the FNES scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FNES() => ScalarOperation
begin
    return ScalarOperation_FNES;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FNES() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;
// DOC-END: operation
