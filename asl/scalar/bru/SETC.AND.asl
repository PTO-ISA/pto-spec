// PTO-INSTRUCTION: {"assembly":["setc.and SrcL, SrcR<.sw, .uw, .not>"],"block":[],"catalog_indices":[406],"catalog_records":[{"asm":"setc.and SrcL, SrcR<.sw, .uw, .not>","constraints":[],"encoding":[{"index":0,"mask":"0xf8007fff","match":"0x00002065","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"setc_and_32_90b4e93ef9d4","length_bits":32,"mnemonic":"SETC.AND","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"SETC.AND","summary":"Execute the SETC.AND scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-SETC-AND","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_AND() => ScalarOperation
begin
    return ScalarOperation_SETC_AND;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;
// DOC-END: operation
