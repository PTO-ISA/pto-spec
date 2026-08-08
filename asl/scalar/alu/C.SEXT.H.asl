// PTO-INSTRUCTION: {"assembly":["c.sext.h srcL, ->t"],"block":[],"catalog_indices":[48],"catalog_records":[{"asm":"c.sext.h srcL, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x481c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_sext_h_16_90cb7ea36bd3","length_bits":16,"mnemonic":"C.SEXT.H","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExtendScalarValue","status":"accepted"}],"classification":["alu"],"mnemonic":"C.SEXT.H","summary":"Execute the C.SEXT.H scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-SEXT-H","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SEXT_H() => ScalarOperation
begin
    return ScalarOperation_C_SEXT_H;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SEXT_H() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtendScalarValue;
end;
// DOC-END: operation
