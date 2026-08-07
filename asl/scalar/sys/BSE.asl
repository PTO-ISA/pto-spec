// PTO-INSTRUCTION: {"assembly":["bse SrcL"],"block":[],"catalog_indices":[25],"catalog_records":[{"asm":"bse SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0000002b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bse_32_883b5167edbc","length_bits":32,"mnemonic":"BSE","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteControlRequest","status":"accepted"}],"classification":["sys"],"mnemonic":"BSE","summary":"Execute the BSE scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BSE() => ScalarOperation
begin
    return ScalarOperation_BSE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;
// DOC-END: operation
