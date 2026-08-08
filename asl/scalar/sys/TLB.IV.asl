// PTO-INSTRUCTION: {"assembly":["tlb.iv SrcL"],"block":[],"catalog_indices":[468],"catalog_records":[{"asm":"tlb.iv SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0010702b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"tlb_iv_32_bf0a5d1ea211","length_bits":32,"mnemonic":"TLB.IV","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted","semantic_summary":"TLB.IV - Perform this mnemonic's cache, TLB, or bundle maintenance operation."}],"classification":["sys"],"mnemonic":"TLB.IV","summary":"TLB.IV - Perform this mnemonic's cache, TLB, or bundle maintenance operation.","surface":"scalar","id":"PTO-SCALAR-TLB-IV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLB_IV() => ScalarOperation
begin
    return ScalarOperation_TLB_IV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TLB_IV() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
