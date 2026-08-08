// PTO-INSTRUCTION: {"assembly":["hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1"],"block":[],"catalog_indices":[229],"catalog_records":[{"asm":"hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0600707f07ff","match":"0x00007047000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":43,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_maddw_48_6fac897f0264","length_bits":48,"mnemonic":"HL.MADDW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarMultiplyAddPair","status":"accepted","semantic_summary":"HL.MADDW - Compute multiply-add and return the scalar result pair."}],"classification":["alu"],"mnemonic":"HL.MADDW","summary":"HL.MADDW - Compute multiply-add and return the scalar result pair.","surface":"scalar","id":"PTO-SCALAR-HL-MADDW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_MADDW() => ScalarOperation
begin
    return ScalarOperation_HL_MADDW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
// DOC-END: operation
