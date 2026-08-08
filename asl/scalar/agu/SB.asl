// PTO-INSTRUCTION: {"assembly":["sb SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]"],"block":[],"catalog_indices":[385],"catalog_records":[{"asm":"sb SrcD, [SrcL, SrcR<{.sw,.uw,.neg}>]","constraints":[],"encoding":[{"index":0,"mask":"0x00007fff","match":"0x00000049","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"sb_32_43c106ae3749","length_bits":32,"mnemonic":"SB","semantic_family":"AGU","semantic_group":"STA/BASE_REG","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"SB","summary":"Execute the SB scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SB","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SB() => ScalarOperation
begin
    return ScalarOperation_SB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SB() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
