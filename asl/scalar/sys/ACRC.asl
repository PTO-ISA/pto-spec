// PTO-INSTRUCTION: {"assembly":["acrc rst_type"],"block":[],"catalog_indices":[0],"catalog_records":[{"asm":"acrc rst_type","constraints":[],"encoding":[{"index":0,"mask":"0xff0fffff","match":"0x0000302b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RST_Type","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"acrc_32_a9c0e33f9904","length_bits":32,"mnemonic":"ACRC","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ArchitectureCloseRequest","status":"accepted"}],"classification":["sys"],"mnemonic":"ACRC","summary":"Execute the ACRC scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ACRC() => ScalarOperation
begin
    return ScalarOperation_ACRC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ACRC() => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureCloseRequest;
end;
// DOC-END: operation
