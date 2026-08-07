// PTO-INSTRUCTION: {"assembly":["setc.or SrcL, SrcR<.sw, .uw, .not>"],"block":[],"catalog_indices":[420],"catalog_records":[{"asm":"setc.or SrcL, SrcR<.sw, .uw, .not>","constraints":[],"encoding":[{"index":0,"mask":"0xf8007fff","match":"0x00003065","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcRType","pieces":[{"instruction_lsb":25,"value_lsb":0,"width":2}],"signedness":"encoding-defined","width":2}],"form_id":"setc_or_32_740134c709d2","length_bits":32,"mnemonic":"SETC.OR","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"SETC.OR","summary":"Execute the SETC.OR scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_OR() => ScalarOperation
begin
    return ScalarOperation_SETC_OR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;
// DOC-END: operation
