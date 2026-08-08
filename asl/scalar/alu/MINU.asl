// PTO-INSTRUCTION: {"assembly":["minu SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[369],"catalog_records":[{"asm":"minu SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x0800505b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"minu_32_9bdb71ef7b19","length_bits":32,"mnemonic":"MINU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarBinary","status":"accepted","semantic_summary":"MINU - Compute this mnemonic's binary scalar operation and write the selected destination."}],"classification":["alu"],"mnemonic":"MINU","summary":"MINU - Compute this mnemonic's binary scalar operation and write the selected destination.","surface":"scalar","id":"PTO-SCALAR-MINU","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MINU() => ScalarOperation
begin
    return ScalarOperation_MINU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MINU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
// DOC-END: operation
