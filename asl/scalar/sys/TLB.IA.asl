// PTO-INSTRUCTION: {"assembly":["tlb.ia SrcL"],"block":[],"catalog_indices":[465],"catalog_records":[{"asm":"tlb.ia SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000702b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"tlb_ia_32_e794d6bf347e","length_bits":32,"mnemonic":"TLB.IA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"TLB.IA","summary":"Execute the TLB.IA scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-TLB-IA","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLB_IA() => ScalarOperation
begin
    return ScalarOperation_TLB_IA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TLB_IA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
