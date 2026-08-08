// PTO-INSTRUCTION: {"assembly":["b.geu SrcL, SrcR, label"],"block":[],"catalog_indices":[14],"catalog_records":[{"asm":"b.geu SrcL, SrcR, label","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00005027","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}],"signedness":"signed","width":12}],"form_id":"b_geu_32_43a6e57dce55","length_bits":32,"mnemonic":"B.GEU","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"BranchRelative","status":"accepted"}],"classification":["bru"],"mnemonic":"B.GEU","summary":"Execute the B.GEU scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-B-GEU","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_B_GEU() => ScalarOperation
begin
    return ScalarOperation_B_GEU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_B_GEU() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
// DOC-END: operation
