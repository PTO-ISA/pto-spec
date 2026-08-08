// PTO-INSTRUCTION: {"assembly":["srai SrcL, shamt, ->{t, u, Rd}"],"block":[],"catalog_indices":[434],"catalog_records":[{"asm":"srai SrcL, shamt, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfc00707f","match":"0x00006015","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"srai_32_e471ea84d4fd","length_bits":32,"mnemonic":"SRAI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted","semantic_summary":"SRAI - Compute this mnemonic's binary scalar operation and write the selected destination."}],"classification":["alu"],"mnemonic":"SRAI","summary":"SRAI - Compute this mnemonic's binary scalar operation and write the selected destination.","surface":"scalar","id":"PTO-SCALAR-SRAI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SRAI() => ScalarOperation
begin
    return ScalarOperation_SRAI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SRAI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
