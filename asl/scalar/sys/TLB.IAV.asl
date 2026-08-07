// PTO-INSTRUCTION: {"assembly":["tlb.iav SrcL"],"block":[],"catalog_indices":[467],"catalog_records":[{"asm":"tlb.iav SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0020702b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"tlb_iav_32_95f4937d2917","length_bits":32,"mnemonic":"TLB.IAV","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"TLB.IAV","summary":"Execute the TLB.IAV scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLB_IAV() => ScalarOperation
begin
    return ScalarOperation_TLB_IAV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TLB_IAV() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
