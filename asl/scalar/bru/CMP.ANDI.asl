// PTO-INSTRUCTION: {"assembly":["cmp.andi SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[64],"catalog_records":[{"asm":"cmp.andi SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002055","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"cmp_andi_32_da7a5391738d","length_bits":32,"mnemonic":"CMP.ANDI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteCompareLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"CMP.ANDI","summary":"Execute the CMP.ANDI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CMP_ANDI() => ScalarOperation
begin
    return ScalarOperation_CMP_ANDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CMP_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;
// DOC-END: operation
