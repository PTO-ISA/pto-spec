// PTO-INSTRUCTION: {"assembly":["c.zext.h srcL, ->t"],"block":[],"catalog_indices":[56],"catalog_records":[{"asm":"c.zext.h srcL, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x601c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_zext_h_16_4c0976791cbc","length_bits":16,"mnemonic":"C.ZEXT.H","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtendScalarValue","status":"accepted"}],"classification":["alu"],"mnemonic":"C.ZEXT.H","summary":"Execute the C.ZEXT.H scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_ZEXT_H() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_H;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_ZEXT_H() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
// DOC-END: operation
