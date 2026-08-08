// PTO-INSTRUCTION: {"assembly":["hl.mul SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[232],"catalog_records":[{"asm":"hl.mul SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00000047000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_mul_48_0d059ff178fb","length_bits":48,"mnemonic":"HL.MUL","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarMultiplyPair","status":"accepted","semantic_summary":"HL.MUL - Compute the full-width scalar product as a result pair."}],"classification":["alu"],"mnemonic":"HL.MUL","summary":"HL.MUL - Compute the full-width scalar product as a result pair.","surface":"scalar","id":"PTO-SCALAR-HL-MUL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_MUL() => ScalarOperation
begin
    return ScalarOperation_HL_MUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
// DOC-END: operation
