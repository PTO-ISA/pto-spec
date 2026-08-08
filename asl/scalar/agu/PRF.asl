// PTO-INSTRUCTION: {"assembly":["prf [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]"],"block":[],"catalog_indices":[378],"catalog_records":[{"asm":"prf [SrcL, SrcR<{.sw,.uw,.neg}><<<shamt>]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00007009","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"prf_32_30e6dfe4e3ce","length_bits":32,"mnemonic":"PRF","semantic_family":"AGU","semantic_group":"LDA/BASE_REG","semantic_handler":"ScalarPrefetch","status":"accepted"}],"classification":["agu"],"mnemonic":"PRF","summary":"Execute the PRF scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-PRF","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_PRF() => ScalarOperation
begin
    return ScalarOperation_PRF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_PRF() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
// DOC-END: operation
