// PTO-INSTRUCTION: {"assembly":["remu SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[381],"catalog_records":[{"asm":"remu SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00005057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"remu_32_d7a5d1ebbbf5","length_bits":32,"mnemonic":"REMU","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarRemainderUnsigned","status":"accepted"}],"classification":["alu"],"mnemonic":"REMU","summary":"Execute the REMU scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-REMU","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_REMU() => ScalarOperation
begin
    return ScalarOperation_REMU;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsigned;
end;
// DOC-END: operation
