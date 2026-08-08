// PTO-INSTRUCTION: {"assembly":["bis SrcL, M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[24],"catalog_records":[{"asm":"bis SrcL, M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003067","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imml","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"imms","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"bis_32_bca5d1a80f32","length_bits":32,"mnemonic":"BIS","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ModifyBitfield","status":"accepted","semantic_summary":"BIS - Modify the selected scalar bitfield."}],"classification":["alu"],"mnemonic":"BIS","summary":"BIS - Modify the selected scalar bitfield.","surface":"scalar","id":"PTO-SCALAR-BIS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_BIS() => ScalarOperation
begin
    return ScalarOperation_BIS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BIS() => ScalarSemanticHandler
begin
    return ScalarHandler_ModifyBitfield;
end;
// DOC-END: operation
