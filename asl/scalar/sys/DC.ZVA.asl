// PTO-INSTRUCTION: {"assembly":["dc.zva SrcL"],"block":[],"catalog_indices":[88],"catalog_records":[{"asm":"dc.zva SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0070602b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"dc_zva_32_0859a1d7aa5b","length_bits":32,"mnemonic":"DC.ZVA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"DC.ZVA","summary":"Execute the DC.ZVA scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_DC_ZVA() => ScalarOperation
begin
    return ScalarOperation_DC_ZVA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_DC_ZVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
