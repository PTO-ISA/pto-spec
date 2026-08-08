// PTO-INSTRUCTION: {"assembly":["or SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}"],"block":[],"catalog_indices":[374],"catalog_records":[{"asm":"or SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003005","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2},{"name":"shamt","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"or_32_a7fb80e78831","length_bits":32,"mnemonic":"OR","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted","semantic_summary":"OR - Compute this mnemonic's binary scalar operation and write the selected destination."}],"classification":["alu"],"mnemonic":"OR","summary":"OR - Compute this mnemonic's binary scalar operation and write the selected destination.","surface":"scalar","id":"PTO-SCALAR-OR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_OR() => ScalarOperation
begin
    return ScalarOperation_OR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
