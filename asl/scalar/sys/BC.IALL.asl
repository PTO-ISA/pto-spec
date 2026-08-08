// PTO-INSTRUCTION: {"assembly":["bc.iall"],"block":[],"catalog_indices":[20],"catalog_records":[{"asm":"bc.iall","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0010402b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"bc_iall_32_fdceb48516a8","length_bits":32,"mnemonic":"BC.IALL","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"BC.IALL","summary":"Execute the BC.IALL scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-BC-IALL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BC_IALL() => ScalarOperation
begin
    return ScalarOperation_BC_IALL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BC_IALL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
