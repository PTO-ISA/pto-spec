// PTO-INSTRUCTION: {"assembly":["hl.addiw SrcL, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[126],"catalog_records":[{"asm":"hl.addiw SrcL, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00000035000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"unsigned","width":24}],"form_id":"hl_addiw_48_f6d7f5032964","length_bits":48,"mnemonic":"HL.ADDIW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinaryW","status":"accepted","semantic_summary":"HL.ADDIW - Compute this mnemonic's 32-bit binary operation and sign-extend the result."}],"classification":["alu"],"mnemonic":"HL.ADDIW","summary":"HL.ADDIW - Compute this mnemonic's 32-bit binary operation and sign-extend the result.","surface":"scalar","id":"PTO-SCALAR-HL-ADDIW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_ADDIW() => ScalarOperation
begin
    return ScalarOperation_HL_ADDIW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_ADDIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
// DOC-END: operation
