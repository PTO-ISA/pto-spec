// PTO-INSTRUCTION: {"assembly":["andi SrcL, simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[8],"catalog_records":[{"asm":"andi SrcL, simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00002015","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"andi_32_1d9302e57d30","length_bits":32,"mnemonic":"ANDI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted","semantic_summary":"ANDI - Compute this mnemonic's binary scalar operation and write the selected destination."}],"classification":["alu"],"mnemonic":"ANDI","summary":"ANDI - Compute this mnemonic's binary scalar operation and write the selected destination.","surface":"scalar","id":"PTO-SCALAR-ANDI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_ANDI() => ScalarOperation
begin
    return ScalarOperation_ANDI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
