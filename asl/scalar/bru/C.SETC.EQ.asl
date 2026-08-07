// PTO-INSTRUCTION: {"assembly":["c.setc.eq srcL, srcR"],"block":[],"catalog_indices":[43],"catalog_records":[{"asm":"c.setc.eq srcL, srcR","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x0026","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_setc_eq_16_03e6b07a3699","length_bits":16,"mnemonic":"C.SETC.EQ","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted"}],"classification":["bru"],"mnemonic":"C.SETC.EQ","summary":"Execute the C.SETC.EQ scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SETC_EQ() => ScalarOperation
begin
    return ScalarOperation_C_SETC_EQ;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SETC_EQ() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
