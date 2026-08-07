// PTO-INSTRUCTION: {"assembly":["setc.andi SrcL, simm"],"block":[],"catalog_indices":[407],"catalog_records":[{"asm":"setc.andi SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"setc_andi_32_32fe61c0559b","length_bits":32,"mnemonic":"SETC.ANDI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"SETC.ANDI","summary":"Execute the SETC.ANDI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_ANDI() => ScalarOperation
begin
    return ScalarOperation_SETC_ANDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;
// DOC-END: operation
