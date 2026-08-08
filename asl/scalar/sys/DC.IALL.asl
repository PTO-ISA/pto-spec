// PTO-INSTRUCTION: {"assembly":["dc.iall"],"block":[],"catalog_indices":[85],"catalog_records":[{"asm":"dc.iall","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0010602b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"dc_iall_32_3d61563dd077","length_bits":32,"mnemonic":"DC.IALL","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted","semantic_summary":"DC.IALL - Perform this mnemonic's cache, TLB, or bundle maintenance operation."}],"classification":["sys"],"mnemonic":"DC.IALL","summary":"DC.IALL - Perform this mnemonic's cache, TLB, or bundle maintenance operation.","surface":"scalar","id":"PTO-SCALAR-DC-IALL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_IALL() => ScalarOperation
begin
    return ScalarOperation_DC_IALL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_IALL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
