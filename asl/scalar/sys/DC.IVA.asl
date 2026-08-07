// PTO-INSTRUCTION: {"assembly":["dc.iva SrcL"],"block":[],"catalog_indices":[87],"catalog_records":[{"asm":"dc.iva SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000602b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dc_iva_32_0131d0cf364f","length_bits":32,"mnemonic":"DC.IVA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"DC.IVA","summary":"Execute the DC.IVA scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_IVA() => ScalarOperation
begin
    return ScalarOperation_DC_IVA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_IVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
