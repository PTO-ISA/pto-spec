// PTO-INSTRUCTION: {"assembly":["ic.iva SrcL"],"block":[],"catalog_indices":[313],"catalog_records":[{"asm":"ic.iva SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000502b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"ic_iva_32_11b9a61dd8b5","length_bits":32,"mnemonic":"IC.IVA","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"IC.IVA","summary":"Execute the IC.IVA scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_IC_IVA() => ScalarOperation
begin
    return ScalarOperation_IC_IVA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_IC_IVA() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
