// PTO-INSTRUCTION: {"assembly":["setc.eqi SrcL, simm"],"block":[],"catalog_indices":[409],"catalog_records":[{"asm":"setc.eqi SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f","match":"0x00000075","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":15,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":7,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm12","pieces":[{"instruction_lsb":20,"value_lsb":0,"width":12}],"signedness":"signed","width":12}],"form_id":"setc_eqi_32_5b2366a4e55d","length_bits":32,"mnemonic":"SETC.EQI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted","semantic_summary":"SETC.EQI - Compare scalar operands and update the bundle commit condition."}],"classification":["bru"],"mnemonic":"SETC.EQI","summary":"SETC.EQI - Compare scalar operands and update the bundle commit condition.","surface":"scalar","id":"PTO-SCALAR-SETC-EQI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_SETC_EQI() => ScalarOperation
begin
    return ScalarOperation_SETC_EQI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_SETC_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
