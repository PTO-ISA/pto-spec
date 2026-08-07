// PTO-INSTRUCTION: {"assembly":["ic.iall"],"block":[],"catalog_indices":[312],"catalog_records":[{"asm":"ic.iall","constraints":[],"encoding":[{"index":0,"mask":"0xffffffff","match":"0x0010502b","width_bits":32}],"encoding_kind":"L32","fields":[],"form_id":"ic_iall_32_854f0d4d906a","length_bits":32,"mnemonic":"IC.IALL","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteMaintenance","status":"accepted"}],"classification":["sys"],"mnemonic":"IC.IALL","summary":"Execute the IC.IALL scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_IC_IALL() => ScalarOperation
begin
    return ScalarOperation_IC_IALL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_IC_IALL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
// DOC-END: operation
