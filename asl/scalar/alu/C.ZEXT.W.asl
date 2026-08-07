// PTO-INSTRUCTION: {"assembly":["c.zext.w srcL, ->t"],"block":[],"catalog_indices":[57],"catalog_records":[{"asm":"c.zext.w srcL, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x681c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_zext_w_16_e8bc051c7e8c","length_bits":16,"mnemonic":"C.ZEXT.W","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtendScalarValue","status":"accepted"}],"classification":["alu"],"mnemonic":"C.ZEXT.W","summary":"Execute the C.ZEXT.W scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_ZEXT_W() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_W;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_ZEXT_W() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
// DOC-END: operation
