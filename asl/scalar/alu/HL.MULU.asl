// PTO-INSTRUCTION: {"assembly":["hl.mulu SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[233],"catalog_records":[{"asm":"hl.mulu SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00001047000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_mulu_48_85efdc81e8fc","length_bits":48,"mnemonic":"HL.MULU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarMultiplyPair","status":"accepted","semantic_summary":"HL.MULU - Compute the full-width scalar product as a result pair."}],"classification":["alu"],"mnemonic":"HL.MULU","summary":"HL.MULU - Compute the full-width scalar product as a result pair.","surface":"scalar","id":"PTO-SCALAR-HL-MULU","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_MULU() => ScalarOperation
begin
    return ScalarOperation_HL_MULU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_MULU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
// DOC-END: operation
