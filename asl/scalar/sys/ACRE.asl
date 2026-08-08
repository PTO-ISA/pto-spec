// PTO-INSTRUCTION: {"assembly":["acre rra_type"],"block":[],"catalog_indices":[1],"catalog_records":[{"asm":"acre rra_type","constraints":[],"encoding":[{"index":0,"mask":"0xff0fffff","match":"0x0100302b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RRA_Type","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":4}],"signedness":"encoding-defined","width":4}],"form_id":"acre_32_54b80944d32d","length_bits":32,"mnemonic":"ACRE","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ArchitectureEnterRequest","status":"accepted"}],"classification":["sys"],"mnemonic":"ACRE","summary":"Execute the ACRE scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-ACRE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ACRE() => ScalarOperation
begin
    return ScalarOperation_ACRE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ACRE() => ScalarSemanticHandler
begin
    return ScalarHandler_ArchitectureEnterRequest;
end;
// DOC-END: operation
