// PTO-INSTRUCTION: {"assembly":["hl.miadd SrcL, SrcR, uimm, ->{t, u, Rd}"],"block":[],"catalog_indices":[230],"catalog_records":[{"asm":"hl.miadd SrcL, SrcR, uimm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x0000004d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"uimm19","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":4,"value_lsb":7,"width":12}],"signedness":"unsigned","width":19}],"form_id":"hl_miadd_48_ec5127b6dfd6","length_bits":48,"mnemonic":"HL.MIADD","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarMultiplyImmediateAdd","status":"accepted","semantic_summary":"HL.MIADD - Multiply by the encoded immediate and add the scalar source."}],"classification":["alu"],"mnemonic":"HL.MIADD","summary":"HL.MIADD - Multiply by the encoded immediate and add the scalar source.","surface":"scalar","id":"PTO-SCALAR-HL-MIADD","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_MIADD() => ScalarOperation
begin
    return ScalarOperation_HL_MIADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_MIADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyImmediateAdd;
end;
// DOC-END: operation
