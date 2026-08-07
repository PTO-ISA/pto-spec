// PTO-INSTRUCTION: {"assembly":["assert SrcL"],"block":[],"catalog_indices":[11],"catalog_records":[{"asm":"assert SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000102b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"assert_32_f05d67874ae5","length_bits":32,"mnemonic":"ASSERT","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ArchitectureAssert","status":"accepted"}],"classification":["sys"],"mnemonic":"ASSERT","summary":"Execute the ASSERT scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ASSERT() => ScalarOperation
begin
    return ScalarOperation_ASSERT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ASSERT() => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureAssert;
end;
// DOC-END: operation
