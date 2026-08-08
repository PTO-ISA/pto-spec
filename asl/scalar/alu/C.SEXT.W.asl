// PTO-INSTRUCTION: {"assembly":["c.sext.w srcL, ->t"],"block":[],"catalog_indices":[49],"catalog_records":[{"asm":"c.sext.w srcL, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x501c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_sext_w_16_f2bb13f0797b","length_bits":16,"mnemonic":"C.SEXT.W","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtendScalarValue","status":"accepted","semantic_summary":"C.SEXT.W - Sign-extend or zero-extend the selected scalar subword."}],"classification":["alu"],"mnemonic":"C.SEXT.W","summary":"C.SEXT.W - Sign-extend or zero-extend the selected scalar subword.","surface":"scalar","id":"PTO-SCALAR-C-SEXT-W","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SEXT_W() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_W;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SEXT_W() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
// DOC-END: operation
