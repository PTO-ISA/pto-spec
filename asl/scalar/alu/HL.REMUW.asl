// PTO-INSTRUCTION: {"assembly":["hl.remuw SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[242],"catalog_records":[{"asm":"hl.remuw SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00007057000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_remuw_48_26ea6e70f2fc","length_bits":48,"mnemonic":"HL.REMUW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarDividePairW","status":"accepted","semantic_summary":"HL.REMUW - Compute 32-bit quotient and remainder as a sign-extended result pair."}],"classification":["alu"],"mnemonic":"HL.REMUW","summary":"HL.REMUW - Compute 32-bit quotient and remainder as a sign-extended result pair.","surface":"scalar","id":"PTO-SCALAR-HL-REMUW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_REMUW() => ScalarOperation
begin
    return ScalarOperation_HL_REMUW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
// DOC-END: operation
