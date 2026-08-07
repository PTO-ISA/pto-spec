// PTO-INSTRUCTION: {"assembly":["tlb.iall"],"block":[],"catalog_indices":[466],"catalog_records":[{"asm":"tlb.iall","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0030702b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"tlb_iall_32_0fb421b85c88","length_bits":32,"mnemonic":"TLB.IALL","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"TLB.IALL","summary":"Execute the TLB.IALL scalar instruction contract.","surface":"scalar"}
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
