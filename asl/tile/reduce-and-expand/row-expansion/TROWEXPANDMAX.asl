// PTO-INSTRUCTION: {"assembly":["TROWEXPANDMAX <bundle operands>"],"block":["BSTART.SFU TROWEXPANDMAX, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[49],"catalog_records":[{"arguments":[{"constant":"TileExpand_MAX"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":9,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TROWEXPANDMAX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"broadcast-source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x049","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:broadcast-source"]}],"classification":["reduce-and-expand","row-expansion"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TROWEXPANDMAX","mnemonic":"TROWEXPANDMAX","summary":"Apply maximum selection while expanding the bound row vector across the source Tile.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWEXPANDMAX() => TileOperation
begin
    return TileOperation_TROWEXPANDMAX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TROWEXPANDMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
// DOC-END: operation
