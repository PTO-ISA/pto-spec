// PTO-INSTRUCTION: {"assembly":["shi SrcL, [SrcR, simm]"],"block":[],"catalog_indices":[427],"catalog_records":[{"asm":"shi SrcL, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001059","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}],"signedness":"signed","width":12}],"form_id":"shi_32_21351c202204","length_bits":32,"mnemonic":"SHI","semantic_family":"AGU","semantic_group":"STA/BASE_IMM","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SHI","summary":"Execute the SHI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SHI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SHI() => ScalarOperation
begin
    return ScalarOperation_SHI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SHI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
