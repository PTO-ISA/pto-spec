// PTO-INSTRUCTION: {"assembly":["TMOV <bundle operands>"],"block":["BSTART.TLSU TMOV, DataType","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[89],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TMOV","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMOV","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":2,"legality_handler":"TileOperandsLegal_TMOV","name":"TMOV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMOV","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["layout-and-rearrangement","layout"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-TMOV","mnemonic":"TMOV","summary":"Copy the source Tile payload and definedness into the destination.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMOV() => TileOperation
begin
    return TileOperation_TMOV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TMOV() => TileSemanticHandler
begin
    return TileHandler_TMOV;
end;
// DOC-END: operation
