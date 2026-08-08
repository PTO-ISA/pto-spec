// PTO-INSTRUCTION: {"assembly":["hl.lis simm, ->{t, u, Rd}"],"block":[],"catalog_indices":[201],"catalog_records":[{"asm":"hl.lis simm, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000007f000f","match":"0x0000000d000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm32","pieces":[{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}],"signedness":"signed","width":32}],"form_id":"hl_lis_48_908853d6ef87","length_bits":48,"mnemonic":"HL.LIS","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MaterializeLongSigned","status":"accepted"}],"classification":["alu"],"mnemonic":"HL.LIS","summary":"Execute the HL.LIS scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-LIS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LIS() => ScalarOperation
begin
    return ScalarOperation_HL_LIS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LIS() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongSigned;
end;
// DOC-END: operation
