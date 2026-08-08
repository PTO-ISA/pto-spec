// PTO-INSTRUCTION: {"assembly":["bc.iva SrcL"],"block":[],"catalog_indices":[21],"catalog_records":[{"asm":"bc.iva SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000402b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bc_iva_32_c166de534c98","length_bits":32,"mnemonic":"BC.IVA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted","semantic_summary":"BC.IVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation."}],"classification":["sys"],"mnemonic":"BC.IVA","summary":"BC.IVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.","surface":"scalar","id":"PTO-SCALAR-BC-IVA","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BC_IVA() => ScalarOperation
begin
    return ScalarOperation_BC_IVA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BC_IVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
