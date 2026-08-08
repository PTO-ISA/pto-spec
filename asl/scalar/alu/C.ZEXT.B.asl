// PTO-INSTRUCTION: {"assembly":["c.zext.b srcL, ->t"],"block":[],"catalog_indices":[55],"catalog_records":[{"asm":"c.zext.b srcL, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x581c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_zext_b_16_7ea1a59fa2da","length_bits":16,"mnemonic":"C.ZEXT.B","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtendScalarValue","status":"accepted","semantic_summary":"C.ZEXT.B - Sign-extend or zero-extend the selected scalar subword."}],"classification":["alu"],"mnemonic":"C.ZEXT.B","summary":"C.ZEXT.B - Sign-extend or zero-extend the selected scalar subword.","surface":"scalar","id":"PTO-SCALAR-C-ZEXT-B","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_ZEXT_B() => ScalarOperation
begin
    return ScalarOperation_C_ZEXT_B;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_ZEXT_B() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
// DOC-END: operation
