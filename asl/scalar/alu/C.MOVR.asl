// PTO-INSTRUCTION: {"assembly":["c.movr SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[40],"catalog_records":[{"asm":"c.movr SrcL, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x003f","match":"0x0006","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_movr_16_80d2b5f3580b","length_bits":16,"mnemonic":"C.MOVR","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MoveScalarValue","status":"accepted","semantic_summary":"C.MOVR - Move the scalar source to the selected destination."}],"classification":["alu"],"mnemonic":"C.MOVR","summary":"C.MOVR - Move the scalar source to the selected destination.","surface":"scalar","id":"PTO-SCALAR-C-MOVR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_MOVR() => ScalarOperation
begin
    return ScalarOperation_C_MOVR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_MOVR() => ScalarSemanticHandler
begin
    return ScalarHandler_MoveScalarValue;
end;
// DOC-END: operation
