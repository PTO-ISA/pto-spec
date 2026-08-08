// PTO-INSTRUCTION: {"assembly":["ori SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[375],"catalog_records":[{"asm":"ori SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003015","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"ori_32_413a6cc76e9a","length_bits":32,"mnemonic":"ORI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted","semantic_summary":"ORI - Compute this mnemonic's binary scalar operation and write the selected destination."}],"classification":["alu"],"mnemonic":"ORI","summary":"ORI - Compute this mnemonic's binary scalar operation and write the selected destination.","surface":"scalar","id":"PTO-SCALAR-ORI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ORI() => ScalarOperation
begin
    return ScalarOperation_ORI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
