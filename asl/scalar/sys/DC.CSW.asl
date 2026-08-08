// PTO-INSTRUCTION: {"assembly":["dc.csw SrcL"],"block":[],"catalog_indices":[83],"catalog_records":[{"asm":"dc.csw SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0050602b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dc_csw_32_2719115a9246","length_bits":32,"mnemonic":"DC.CSW","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"DC.CSW","summary":"Execute the DC.CSW scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-DC-CSW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_CSW() => ScalarOperation
begin
    return ScalarOperation_DC_CSW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_CSW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
