// PTO-INSTRUCTION: {"assembly":["hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1"],"block":[],"catalog_indices":[136],"catalog_records":[{"asm":"hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f07ff","match":"0x0000205d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7}],"signedness":"encoding-defined","width":7}],"form_id":"hl_ccatw_48_24a85ea4659c","length_bits":48,"mnemonic":"HL.CCATW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ExecuteConcatenatePairW","status":"accepted","semantic_summary":"HL.CCATW - Concatenate two 32-bit values into a sign-extended result pair."}],"classification":["alu"],"mnemonic":"HL.CCATW","summary":"HL.CCATW - Concatenate two 32-bit values into a sign-extended result pair.","surface":"scalar","id":"PTO-SCALAR-HL-CCATW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_CCATW() => ScalarOperation
begin
    return ScalarOperation_HL_CCATW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_CCATW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePairW;
end;
// DOC-END: operation
