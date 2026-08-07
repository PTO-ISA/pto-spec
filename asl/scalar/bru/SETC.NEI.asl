// PTO-INSTRUCTION: {"assembly":["setc.nei SrcL, simm"],"block":[],"catalog_indices":[419],"catalog_records":[{"asm":"setc.nei SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"setc_nei_32_fa01e973ab76","length_bits":32,"mnemonic":"SETC.NEI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted"}],"classification":["bru"],"mnemonic":"SETC.NEI","summary":"Execute the SETC.NEI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_NEI() => ScalarOperation
begin
    return ScalarOperation_SETC_NEI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
