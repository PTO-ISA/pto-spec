// PTO-INSTRUCTION: {"assembly":["hl.madd SrcL, SrcR, SrcD, ->Dst0, Dst1"],"block":[],"catalog_indices":[228],"catalog_records":[{"asm":"hl.madd SrcL, SrcR, SrcD, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0600707f07ff","match":"0x00006047000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_madd_48_b062d741fd99","length_bits":48,"mnemonic":"HL.MADD","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarMultiplyAddPair","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.MADD","summary":"Execute the HL.MADD scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_MADD() => ScalarOperation
begin
    return ScalarOperation_HL_MADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
// DOC-END: operation
