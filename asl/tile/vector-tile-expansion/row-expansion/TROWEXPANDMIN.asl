// PTO-INSTRUCTION: {"assembly":["TROWEXPANDMIN <bundle operands>"],"block":["BSTART.TEPL TROWEXPANDMIN, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[50],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TROWEXPANDMIN","selector":"0x04A","semantic_handler":"ExecuteTileExpand","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"broadcast-source"}],"arguments":[{"constant":"TileExpand_MIN"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":2,"function":10,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileExpand","effect_contract":"ExecuteTileExpand","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:broadcast-source"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["vector-tile-expansion","row-expansion"],"mnemonic":"TROWEXPANDMIN","summary":"Execute the TROWEXPANDMIN Tile operation contract.","surface":"tile","id":"PTO-TILE-TROWEXPANDMIN","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWEXPANDMIN() => TileOperation
begin
    return TileOperation_TROWEXPANDMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TROWEXPANDMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
// DOC-END: operation
