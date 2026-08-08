// PTO-INSTRUCTION: {"assembly":["hl.ccat SrcL, SrcR, shamt, ->Dst0, Dst1"],"block":[],"catalog_indices":[135],"catalog_records":[{"asm":"hl.ccat SrcL, SrcR, shamt, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f07ff","match":"0x0000105d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7}],"signedness":"encoding-defined","width":7}],"form_id":"hl_ccat_48_a1200d8bf5ac","length_bits":48,"mnemonic":"HL.CCAT","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteConcatenatePair","status":"accepted","semantic_summary":"HL.CCAT - Concatenate two scalar values into a result pair."}],"classification":["alu"],"mnemonic":"HL.CCAT","summary":"HL.CCAT - Concatenate two scalar values into a result pair.","surface":"scalar","id":"PTO-SCALAR-HL-CCAT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CCAT() => ScalarOperation
begin
    return ScalarOperation_HL_CCAT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CCAT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePair;
end;
// DOC-END: operation
