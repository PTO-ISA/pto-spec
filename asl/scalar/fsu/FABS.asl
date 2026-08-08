// PTO-INSTRUCTION: {"assembly":["fabs.{T} SrcL, ->{t, u, Rd}"],"block":[],"catalog_indices":[95],"catalog_records":[{"asm":"fabs.{T} SrcL, ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0xf9f0707f","match":"0x0000007b","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"fabs_32_9515e008bf17","length_bits":32,"mnemonic":"FABS","semantic_family":"FSU","semantic_group":"FSU","semantic_handler":"FloatingUnary","status":"accepted"}],"classification":["fsu"],"mnemonic":"FABS","summary":"Execute the FABS scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-FABS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_FABS() => ScalarOperation
begin
    return ScalarOperation_FABS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_FABS() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingUnary;
end;
// DOC-END: operation
