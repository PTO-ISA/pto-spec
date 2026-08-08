// PTO-INSTRUCTION: {"assembly":["c.break imm"],"block":[],"catalog_indices":[36],"catalog_records":[{"asm":"c.break imm","constraints":[],"encoding":[{"index":0,"mask":"0xf83f","match":"0xc02c","width_bits":16}],"encoding_kind":"C16","fields":[{"name":"imm5","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"c_ebreak_16_7f9c245fa13c","length_bits":16,"mnemonic":"C.EBREAK","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"SoftwareBreakpoint","status":"accepted"}],"classification":["sys"],"mnemonic":"C.EBREAK","summary":"Execute the C.EBREAK scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-C-EBREAK","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_C_EBREAK() => ScalarOperation
begin
    return ScalarOperation_C_EBREAK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_C_EBREAK() => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;
// DOC-END: operation
