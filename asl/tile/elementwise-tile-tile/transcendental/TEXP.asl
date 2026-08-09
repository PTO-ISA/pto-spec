// PTO-INSTRUCTION: {"assembly":["TEXP <bundle operands>"],"block":["BSTART.SFU TEXP, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[16],"catalog_records":[{"arguments":[{"constant":"TileUnary_EXP"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileUnary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":18,"legality_handler":"TileOperandsLegal_ExecuteTileUnary","mode":0,"name":"TEXP","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x012","semantic_handler":"ExecuteTileUnary","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["elementwise-tile-tile","transcendental"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TEXP","mnemonic":"TEXP","summary":"Apply elementwise exponential to the source Tile.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TEXP() => TileOperation
begin
    return TileOperation_TEXP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TEXP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;
// DOC-END: operation
