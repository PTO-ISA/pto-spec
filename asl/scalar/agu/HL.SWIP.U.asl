// PTO-INSTRUCTION: {"assembly":["hl.swip.u SrcD, SrcD1, [SrcR, simm]"],"block":[],"catalog_indices":[307],"catalog_records":[{"asm":"hl.swip.u SrcD, SrcD1, [SrcR, simm]","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00006059001e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"SrcD","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD1","pieces":[{"instruction_lsb":6,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":11,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_swip_u_48_e2dc917c8505","length_bits":48,"mnemonic":"HL.SWIP.U","semantic_family":"AGU","semantic_group":"STA/PAIR","semantic_handler":"ExecuteScalarStorePair","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SWIP.U","summary":"Execute the HL.SWIP.U scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SWIP_U() => ScalarOperation
begin
    return ScalarOperation_HL_SWIP_U;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SWIP_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStorePair;
end;
// DOC-END: operation
