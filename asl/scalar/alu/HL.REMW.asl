// PTO-INSTRUCTION: {"assembly":["hl.remw SrcL, SrcR, ->Dst0, Dst1"],"block":[],"catalog_indices":[243],"catalog_records":[{"asm":"hl.remw SrcL, SrcR, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f07ff","match":"0x00006057000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"hl_remw_48_3acb485d39a7","length_bits":48,"mnemonic":"HL.REMW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteScalarDividePairW","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.REMW","summary":"Execute the HL.REMW scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-REMW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_REMW() => ScalarOperation
begin
    return ScalarOperation_HL_REMW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarDividePairW;
end;
// DOC-END: operation
