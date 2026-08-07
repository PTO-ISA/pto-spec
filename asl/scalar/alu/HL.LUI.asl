// PTO-INSTRUCTION: {"assembly":["hl.lui imm, ->{t, u, Rd}"],"block":[],"catalog_indices":[203],"catalog_records":[{"asm":"hl.lui imm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f000f","match":"0x00000017000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"encoding-defined","width":32}],"form_id":"hl_lui_48_255991889818","length_bits":48,"mnemonic":"HL.LUI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MaterializeLongSigned","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.LUI","summary":"Execute the HL.LUI scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LUI() => ScalarOperation
begin
    return ScalarOperation_HL_LUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongSigned;
end;
// DOC-END: operation
