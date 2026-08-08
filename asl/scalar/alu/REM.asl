// PTO-INSTRUCTION: {"assembly":["rem SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[380],"catalog_records":[{"asm":"rem SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00004057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"rem_32_0abbd6a3b865","length_bits":32,"mnemonic":"REM","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarRemainderSigned","status":"accepted","semantic_summary":"REM - Compute signed scalar remainder."}],"classification":["alu"],"mnemonic":"REM","summary":"REM - Compute signed scalar remainder.","surface":"scalar","id":"PTO-SCALAR-REM","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_REM() => ScalarOperation
begin
    return ScalarOperation_REM;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSigned;
end;
// DOC-END: operation
