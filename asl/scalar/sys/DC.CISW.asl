// PTO-INSTRUCTION: {"assembly":["dc.cisw SrcL"],"block":[],"catalog_indices":[81],"catalog_records":[{"asm":"dc.cisw SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0060602b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dc_cisw_32_166b7135e3c1","length_bits":32,"mnemonic":"DC.CISW","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted","semantic_summary":"DC.CISW - Perform this mnemonic's cache, TLB, or bundle maintenance operation."}],"classification":["sys"],"mnemonic":"DC.CISW","summary":"DC.CISW - Perform this mnemonic's cache, TLB, or bundle maintenance operation.","surface":"scalar","id":"PTO-SCALAR-DC-CISW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_CISW() => ScalarOperation
begin
    return ScalarOperation_DC_CISW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_CISW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
