// PTO-INSTRUCTION: {"assembly":["xor SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}"],"block":[],"catalog_indices":[470],"catalog_records":[{"asm":"xor SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00004005","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"xor_32_33510860c585","length_bits":32,"mnemonic":"XOR","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted"}],"classification":["alu"],"mnemonic":"XOR","summary":"Execute the XOR scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_XOR() => ScalarOperation
begin
    return ScalarOperation_XOR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_XOR() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
