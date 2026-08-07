// PTO-INSTRUCTION: {"assembly":["bwe SrcL"],"block":[],"catalog_indices":[26],"catalog_records":[{"asm":"bwe SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0010002b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bwe_32_e5a5240bdf9b","length_bits":32,"mnemonic":"BWE","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteControlRequest","status":"accepted"}],"classification":["sys"],"mnemonic":"BWE","summary":"Execute the BWE scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BWE() => ScalarOperation
begin
    return ScalarOperation_BWE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BWE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;
// DOC-END: operation
