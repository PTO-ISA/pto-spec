// PTO-INSTRUCTION: {"assembly":["mul SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[370],"catalog_records":[{"asm":"mul SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00000047","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"mul_32_9f2affd8efb8","length_bits":32,"mnemonic":"MUL","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"MultiplyWord","status":"accepted"}],"classification":["alu"],"mnemonic":"MUL","summary":"Execute the MUL scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-MUL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MUL() => ScalarOperation
begin
    return ScalarOperation_MUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
// DOC-END: operation
