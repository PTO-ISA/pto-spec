// PTO-INSTRUCTION: {"assembly":["TREMS <bundle operands>"],"block":["BSTART.TEPL TREMS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[29],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TREMS","selector":"0x024","semantic_handler":"ExecuteTileScalar","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"}],"arguments":[{"constant":"TileBinary_REM"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"mode":1,"function":4,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileScalar","effect_contract":"ExecuteTileScalar","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["tile-scalar-elementwise","arithmetic"],"mnemonic":"TREMS","summary":"Apply elementwise remainder between the source Tile and bound scalar.","surface":"tile","id":"PTO-TILE-TREMS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TREMS() => TileOperation
begin
    return TileOperation_TREMS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TREMS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
// DOC-END: operation
