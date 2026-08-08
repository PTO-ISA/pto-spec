// PTO-INSTRUCTION: {"assembly":["b.z label"],"block":[],"catalog_indices":[19],"catalog_records":[{"asm":"b.z label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00001037","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"simm22","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}],"signedness":"signed","width":22}],"form_id":"b_z_32_753dd3b4fcb6","length_bits":32,"mnemonic":"B.Z","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"BranchRelative","status":"accepted"}],"classification":["bru"],"mnemonic":"B.Z","summary":"Execute the B.Z scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-B-Z","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_B_Z() => ScalarOperation
begin
    return ScalarOperation_B_Z;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_Z() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
// DOC-END: operation
