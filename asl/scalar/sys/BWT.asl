// PTO-INSTRUCTION: {"assembly":["bwt SrcL"],"block":[],"catalog_indices":[28],"catalog_records":[{"asm":"bwt SrcL","constraints":[],"encoding":[{"index":0,"mask":"0xfff07fff","match":"0x0030002b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bwt_32_5a0fe4a8e61f","length_bits":32,"mnemonic":"BWT","semantic_family":"SYS","semantic_group":"SYS","semantic_handler":"ExecuteControlRequest","status":"accepted"}],"classification":["sys"],"mnemonic":"BWT","summary":"Execute the BWT scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BWT() => ScalarOperation
begin
    return ScalarOperation_BWT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BWT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;
// DOC-END: operation
