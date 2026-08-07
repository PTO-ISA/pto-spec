// PTO-INSTRUCTION: {"assembly":["jr SrcL, label"],"block":[],"catalog_indices":[315],"catalog_records":[{"asm":"jr SrcL, label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00006027","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcZero","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}],"signedness":"signed","width":12}],"form_id":"jr_32_c4128e843b05","length_bits":32,"mnemonic":"JR","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"JumpRegister","status":"accepted"}],"classification":["bru"],"mnemonic":"JR","summary":"Execute the JR scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_JR() => ScalarOperation
begin
    return ScalarOperation_JR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_JR() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRegister;
end;
// DOC-END: operation
