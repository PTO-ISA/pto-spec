// PTO-INSTRUCTION: {"assembly":["hl.lwi.upo [SrcL, simm], ->Dst0, Dst1"],"block":[],"catalog_indices":[211],"catalog_records":[{"asm":"hl.lwi.upo [SrcL, simm], ->Dst0, Dst1","constraints":[],"encoding":[{"index":0,"mask":"0x0000707f003f","match":"0x00002029003e","width_bits":48}],"encoding_kind":"HL48","fields":[{"name":"RegDst0","pieces":[{"instruction_lsb":23,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"RegDst1","pieces":[{"instruction_lsb":11,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"SrcL","pieces":[{"instruction_lsb":31,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5},{"name":"simm17","pieces":[{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}],"signedness":"signed","width":17}],"form_id":"hl_lwi_upo_48_1c25d6266934","length_bits":48,"mnemonic":"HL.LWI.UPO","semantic_family":"AGU","semantic_group":"LDA/POST_INDEX","semantic_handler":"ExecuteScalarLoad","status":"accepted"}],"classification":["agu"],"mnemonic":"HL.LWI.UPO","summary":"Execute the HL.LWI.UPO scalar instruction contract.","surface":"scalar"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_HL_LWI_UPO() => ScalarOperation
begin
    return ScalarOperation_HL_LWI_UPO;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_HL_LWI_UPO() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
// DOC-END: operation
