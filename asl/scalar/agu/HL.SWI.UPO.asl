// PTO-INSTRUCTION: {"assembly":["hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}"],"block":[],"catalog_indices":[304],"catalog_records":[{"asm":"hl.swi.upo SrcD, [SrcR, simm], ->{t, u, Rd}","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00006059003e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcD","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcR","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":41,"value_lsb":0,"width":7},{"instruction_lsb":23,"value_lsb":7,"width":5},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_swi_upo_48_243d3c38cd1a","length_bits":48,"mnemonic":"HL.SWI.UPO","semantic_family":"AGU","semantic_group":"STA/POST_INDEX","semantic_handler":"ExecuteScalarStore","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.SWI.UPO","summary":"Execute the HL.SWI.UPO scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_SWI_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_SWI_UPO;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_SWI_UPO() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
// DOC-END: operation
