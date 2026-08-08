// PTO-INSTRUCTION: {"assembly":["c.setc.ne srcL, srcR"],"block":[],"catalog_indices":[44],"catalog_records":[{"asm":"c.setc.ne srcL, srcR","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x0036","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_setc_ne_16_e9092e487e98","length_bits":16,"mnemonic":"C.SETC.NE","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted","semantic_summary":"C.SETC.NE - Compare scalar operands and update the bundle commit condition."}],"classification":["bru"],"mnemonic":"C.SETC.NE","summary":"C.SETC.NE - Compare scalar operands and update the bundle commit condition.","surface":"scalar","id":"PTO-SCALAR-C-SETC-NE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SETC_NE() => ScalarOperation
begin
    return ScalarOperation_C_SETC_NE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SETC_NE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
