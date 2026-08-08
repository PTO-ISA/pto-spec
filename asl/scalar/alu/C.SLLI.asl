// PTO-INSTRUCTION: {"assembly":["c.slli t#1, uimm, ->t"],"block":[],"catalog_indices":[50],"catalog_records":[{"asm":"c.slli t#1, uimm, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x102c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"uimm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"c_slli_16_958a14dc4058","length_bits":16,"mnemonic":"C.SLLI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted"}],"classification":["alu"],"mnemonic":"C.SLLI","summary":"Execute the C.SLLI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-SLLI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SLLI() => ScalarOperation
begin
    return ScalarOperation_C_SLLI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SLLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
