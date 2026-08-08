// PTO-INSTRUCTION: {"assembly":["dc.cva SrcL"],"block":[],"catalog_indices":[84],"catalog_records":[{"asm":"dc.cva SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0020602b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dc_cva_32_166d5a076f0e","length_bits":32,"mnemonic":"DC.CVA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted","semantic_summary":"DC.CVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation."}],"classification":["sys"],"mnemonic":"DC.CVA","summary":"DC.CVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.","surface":"scalar","id":"PTO-SCALAR-DC-CVA","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_CVA() => ScalarOperation
begin
    return ScalarOperation_DC_CVA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_CVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
