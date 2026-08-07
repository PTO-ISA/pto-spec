// PTO-INSTRUCTION: {"assembly":["j label"],"block":[],"catalog_indices":[314],"catalog_records":[{"asm":"j label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000037","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm22","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}],"signedness":"signed","width":22}],"form_id":"j_32_a303cf05af42","length_bits":32,"mnemonic":"J","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"JumpRelative","status":"accepted"}],"classification":["bru"],"mnemonic":"J","summary":"Execute the J scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_J() => ScalarOperation
begin
    return ScalarOperation_J;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_J() => ScalarSemanticHandler
begin
    return ScalarHandler_JumpRelative;
end;
// DOC-END: operation
