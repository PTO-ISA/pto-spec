// PTO-INSTRUCTION: {"assembly":["lui simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[347],"catalog_records":[{"asm":"lui simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f","match":"0x00000017","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imm20","pieces":[{"instruction_lsb":12,"value_lsb":0,"width":20}],"signedness":"encoding-defined","width":20}],"form_id":"lui_32_982113b541d6","length_bits":32,"mnemonic":"LUI","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MaterializeLUI","status":"accepted"}],"classification":["alu"],"mnemonic":"LUI","summary":"Execute the LUI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-LUI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_LUI() => ScalarOperation
begin
    return ScalarOperation_LUI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_LUI() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLUI;
end;
// DOC-END: operation
