// PTO-INSTRUCTION: {"assembly":["TCOLEXPANDMUL <bundle operands>"],"block":["BSTART.TEPL TCOLEXPANDMUL, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[61],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TCOLEXPANDMUL","selector":"0x057","semantic_handler":"ExecuteTileExpand","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"broadcast-source"}],"arguments":[{"constant":"TileExpand_MUL"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":2,"function":23,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileExpand","effect_contract":"ExecuteTileExpand","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:broadcast-source"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["vector-tile-expansion","column-expansion"],"mnemonic":"TCOLEXPANDMUL","summary":"Apply multiplication while expanding the bound col vector across the source Tile.","surface":"tile","id":"PTO-TILE-TCOLEXPANDMUL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLEXPANDMUL() => TileOperation
begin
    return TileOperation_TCOLEXPANDMUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCOLEXPANDMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
// DOC-END: operation
