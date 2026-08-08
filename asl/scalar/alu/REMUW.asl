// PTO-INSTRUCTION: {"assembly":["remuw SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[382],"catalog_records":[{"asm":"remuw SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00007057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"remuw_32_f10ade2f5ccb","length_bits":32,"mnemonic":"REMUW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarRemainderUnsignedW","status":"accepted","semantic_summary":"REMUW - Compute unsigned 32-bit remainder and sign-extend it."}],"classification":["alu"],"mnemonic":"REMUW","summary":"REMUW - Compute unsigned 32-bit remainder and sign-extend it.","surface":"scalar","id":"PTO-SCALAR-REMUW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_REMUW() => ScalarOperation
begin
    return ScalarOperation_REMUW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsignedW;
end;
// DOC-END: operation
