// PTO-INSTRUCTION: {"assembly":["dc.isw SrcL"],"block":[],"catalog_indices":[86],"catalog_records":[{"asm":"dc.isw SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0040602b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dc_isw_32_7940273560b2","length_bits":32,"mnemonic":"DC.ISW","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted","semantic_summary":"DC.ISW - Perform this mnemonic's cache, TLB, or bundle maintenance operation."}],"classification":["sys"],"mnemonic":"DC.ISW","summary":"DC.ISW - Perform this mnemonic's cache, TLB, or bundle maintenance operation.","surface":"scalar","id":"PTO-SCALAR-DC-ISW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_ISW() => ScalarOperation
begin
    return ScalarOperation_DC_ISW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_ISW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
