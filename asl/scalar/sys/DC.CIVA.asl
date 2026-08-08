// PTO-INSTRUCTION: {"assembly":["dc.civa SrcL"],"block":[],"catalog_indices":[82],"catalog_records":[{"asm":"dc.civa SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0030602b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dc_civa_32_265d686549c8","length_bits":32,"mnemonic":"DC.CIVA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted","semantic_summary":"DC.CIVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation."}],"classification":["sys"],"mnemonic":"DC.CIVA","summary":"DC.CIVA - Perform this mnemonic's cache, TLB, or bundle maintenance operation.","surface":"scalar","id":"PTO-SCALAR-DC-CIVA","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_CIVA() => ScalarOperation
begin
    return ScalarOperation_DC_CIVA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_CIVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
