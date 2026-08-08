// PTO-INSTRUCTION: {"assembly":["hl.setc.eqi SrcL, simm"],"block":[],"catalog_indices":[268],"catalog_records":[{"asm":"hl.setc.eqi SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00000075000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_setc_eqi_48_0fe891fb0890","length_bits":48,"mnemonic":"HL.SETC.EQI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommit","status":"accepted","semantic_summary":"HL.SETC.EQI - Compare scalar operands and update the bundle commit condition."}],"classification":["bru"],"mnemonic":"HL.SETC.EQI","summary":"HL.SETC.EQI - Compare scalar operands and update the bundle commit condition.","surface":"scalar","id":"PTO-SCALAR-HL-SETC-EQI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SETC_EQI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_EQI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SETC_EQI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;
// DOC-END: operation
