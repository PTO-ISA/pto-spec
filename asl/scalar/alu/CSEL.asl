// PTO-INSTRUCTION: {"assembly":["csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}"],"block":[],"catalog_indices":[79],"catalog_records":[{"asm":"csel SrcP, SrcL, SrcR<.neg>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000077","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcP","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"csel_32_ba77cbad3c99","length_bits":32,"mnemonic":"CSEL","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarConditionalSelect","status":"accepted"}],"classification":["alu"],"mnemonic":"CSEL","summary":"Execute the CSEL scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_CSEL() => ScalarOperation
begin
    return ScalarOperation_CSEL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_CSEL() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarConditionalSelect;
end;
// DOC-END: operation
