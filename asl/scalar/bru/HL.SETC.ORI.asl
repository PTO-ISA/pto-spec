// PTO-INSTRUCTION: {"assembly":["hl.setc.ori SrcL, simm"],"block":[],"catalog_indices":[274],"catalog_records":[{"asm":"hl.setc.ori SrcL, simm","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f000f","match":"0x00003075000e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"shamt","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm24","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}],"signedness":"signed","width":24}],"form_id":"hl_setc_ori_48_137bce8aeb04","length_bits":48,"mnemonic":"HL.SETC.ORI","semantic_family":"BRU","semantic_group":"BRU","semantic_handler":"ExecuteSetCommitLogical","status":"accepted"}],"classification":["bru"],"mnemonic":"HL.SETC.ORI","summary":"Execute the HL.SETC.ORI scalar instruction contract.","surface":"scalar","id":"PTO-SCALAR-HL-SETC-ORI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SETC_ORI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_ORI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SETC_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;
// DOC-END: operation
