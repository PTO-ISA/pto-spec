// PTO-INSTRUCTION: {"assembly":["tlb.iall"],"block":[],"catalog_indices":[466],"catalog_records":[{"asm":"tlb.iall","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0030702b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"tlb_iall_32_0fb421b85c88","length_bits":32,"mnemonic":"TLB.IALL","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted","semantic_summary":"TLB.IALL - Perform this mnemonic's cache, TLB, or bundle maintenance operation."}],"classification":["sys"],"mnemonic":"TLB.IALL","summary":"TLB.IALL - Perform this mnemonic's cache, TLB, or bundle maintenance operation.","surface":"scalar","id":"PTO-SCALAR-TLB-IALL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLB_IALL() => ScalarOperation
begin
    return ScalarOperation_TLB_IALL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TLB_IALL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
