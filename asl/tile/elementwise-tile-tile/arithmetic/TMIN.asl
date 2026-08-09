// PTO-INSTRUCTION: {"assembly":["TMIN <bundle operands>"],"block":["BSTART.VEC TMIN, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[11],"catalog_records":[{"arguments":[{"constant":"TileBinary_MIN"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":12,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TMIN","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x00C","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["elementwise-tile-tile","arithmetic"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TMIN","mnemonic":"TMIN","summary":"Apply elementwise minimum selection to the two source Tiles.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMIN() => TileOperation
begin
    return TileOperation_TMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;
// DOC-END: operation
