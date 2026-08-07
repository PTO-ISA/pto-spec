// PTO-INSTRUCTION: {"assembly":["c.sext.b srcL, ->t"],"block":[],"catalog_indices":[47],"catalog_records":[{"asm":"c.sext.b srcL, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x401c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_sext_b_16_8ffd07d15409","length_bits":16,"mnemonic":"C.SEXT.B","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtendScalarValue","status":"accepted"}],"classification":["alu"],"mnemonic":"C.SEXT.B","summary":"Execute the C.SEXT.B scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_B;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
// DOC-END: operation
