// PTO-INSTRUCTION: {"assembly":["TCOLEXPANDSUB <bundle operands>"],"block":["BSTART.SFU TCOLEXPANDSUB, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[60],"catalog_records":[{"arguments":[{"constant":"TileExpand_SUB"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":22,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TCOLEXPANDSUB","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"broadcast-source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x056","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:broadcast-source"]}],"classification":["reduce-and-expand","column-expansion"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TCOLEXPANDSUB","mnemonic":"TCOLEXPANDSUB","summary":"Apply subtraction while expanding the bound col vector across the source Tile.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLEXPANDSUB() => TileOperation
begin
    return TileOperation_TCOLEXPANDSUB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCOLEXPANDSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
// DOC-END: operation
