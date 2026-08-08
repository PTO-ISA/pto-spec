// PTO-INSTRUCTION: {"assembly":["setc.ori SrcL, simm"],"block":[],"catalog_indices":[421],"catalog_records":[{"asm":"setc.ori SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00003075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"setc_ori_32_183dc15fad54","length_bits":32,"mnemonic":"SETC.ORI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","status":"accepted","semantic_summary":"SETC.ORI - Combine scalar comparison results and update the bundle commit condition."}],"classification":["bru"],"mnemonic":"SETC.ORI","summary":"SETC.ORI - Combine scalar comparison results and update the bundle commit condition.","surface":"scalar","id":"PTO-SCALAR-SETC-ORI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_ORI() => ScalarOperation
begin
    return ScalarOperation_SETC_ORI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;
// DOC-END: operation
