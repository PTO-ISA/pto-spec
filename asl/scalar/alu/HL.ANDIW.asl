// PTO-INSTRUCTION: {"assembly":["hl.andiw SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[129],"catalog_records":[{"asm":"hl.andiw SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00002035000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_andiw_48_878c6594c6ff","length_bits":48,"mnemonic":"HL.ANDIW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.ANDIW","summary":"Execute the HL.ANDIW scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-ANDIW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_ANDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ANDIW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_ANDIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
// DOC-END: operation
