// PTO-INSTRUCTION: {"assembly":["rev SrcL,  M, N, ->{t, u, Rd}"],"block":[],"catalog_indices":[384],"catalog_records":[{"asm":"rev SrcL,  M, N, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00007067","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"imml","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6},{"name":"immr","pieces":[{"instruction_lsb":26,"value_lsb":0,"width":6}],"signedness":"encoding-defined","width":6}],"form_id":"rev_32_58badc109d49","length_bits":32,"mnemonic":"REV","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ReverseBitfieldBytes","status":"accepted"}],"classification":["alu"],"mnemonic":"REV","summary":"Execute the REV scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-REV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_REV() => ScalarOperation
begin
    return ScalarOperation_REV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_REV() => ScalarSemanticHandler
begin
    return ScalarHandler_ReverseBitfieldBytes;
end;
// DOC-END: operation
