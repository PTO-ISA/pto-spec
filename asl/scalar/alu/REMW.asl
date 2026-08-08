// PTO-INSTRUCTION: {"assembly":["remw SrcL, SrcR, ->{t, u, Rd}"],"block":[],"catalog_indices":[383],"catalog_records":[{"asm":"remw SrcL, SrcR, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xfe00707f","match":"0x00006057","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"remw_32_22659af46ec0","length_bits":32,"mnemonic":"REMW","semantic_family":"ALU","semantic_group":"ALU","semantic_handler":"ScalarRemainderSignedW","status":"accepted"}],"classification":["alu"],"mnemonic":"REMW","summary":"Execute the REMW scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-REMW","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_REMW() => ScalarOperation
begin
    return ScalarOperation_REMW;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSignedW;
end;
// DOC-END: operation
