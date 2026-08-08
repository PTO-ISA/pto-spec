// PTO-INSTRUCTION: {"assembly":["TCOLEXPAND <bundle operands>"],"block":["BSTART.TEPL TCOLEXPAND, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[58],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TCOLEXPAND","selector":"0x054","semantic_handler":"ExecuteTileExpand","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"broadcast-source"}],"arguments":[{"constant":"TileExpand_COPY"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":2,"function":20,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileExpand","effect_contract":"ExecuteTileExpand","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:broadcast-source"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["vector-tile-expansion","column-expansion"],"mnemonic":"TCOLEXPAND","summary":"Apply broadcast while expanding the bound col vector across the source Tile.","surface":"tile","id":"PTO-TILE-TCOLEXPAND","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLEXPAND() => TileOperation
begin
    return TileOperation_TCOLEXPAND;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCOLEXPAND() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
// DOC-END: operation
