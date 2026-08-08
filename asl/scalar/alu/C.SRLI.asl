// PTO-INSTRUCTION: {"assembly":["c.srli t#1, uimm, ->t"],"block":[],"catalog_indices":[51],"catalog_records":[{"asm":"c.srli t#1, uimm, ->t","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0x182c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"uimm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"unsigned","width":5}],"form_id":"c_srli_16_b411862f7820","length_bits":16,"mnemonic":"C.SRLI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted","semantic_summary":"C.SRLI - Compute this mnemonic's binary scalar operation and write the selected destination."}],"classification":["alu"],"mnemonic":"C.SRLI","summary":"C.SRLI - Compute this mnemonic's binary scalar operation and write the selected destination.","surface":"scalar","id":"PTO-SCALAR-C-SRLI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_SRLI() => ScalarOperation
begin
    return ScalarOperation_C_SRLI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_SRLI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
