// PTO-INSTRUCTION: {"assembly":["ebreak imm"],"block":[],"catalog_indices":[94],"catalog_records":[{"asm":"ebreak imm","constraints":[],"encoding":[{"index":0,"mask":"0xf0ffffff","match":"0x0010102b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"imm4","pieces":[{"instruction_lsb":24,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"ebreak_32_4f122d1e6be3","length_bits":32,"mnemonic":"EBREAK","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"SoftwareBreakpoint","status":"accepted"}],"classification":["sys"],"mnemonic":"EBREAK","summary":"Execute the EBREAK scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-EBREAK","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_EBREAK() => ScalarOperation
begin
    return ScalarOperation_EBREAK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_EBREAK() => ScalarSemanticHandler
begin
    return ScalarHandler_SoftwareBreakpoint;
end;
// DOC-END: operation
