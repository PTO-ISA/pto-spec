// PTO-INSTRUCTION: {"assembly":["TMINS <bundle operands>"],"block":["BSTART.VEC TMINS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[36],"catalog_records":[{"arguments":[{"constant":"TileBinary_MIN"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":12,"legality_handler":"TileOperandsLegal_ExecuteTileScalar","mode":1,"name":"TMINS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x02C","semantic_handler":"ExecuteTileScalar","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar"]}],"classification":["tile-scalar-and-immediate","arithmetic"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TMINS","mnemonic":"TMINS","summary":"Apply elementwise minimum selection between the source Tile and bound scalar.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMINS() => TileOperation
begin
    return TileOperation_TMINS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TMINS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
// DOC-END: operation
