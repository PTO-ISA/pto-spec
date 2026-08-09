// PTO-INSTRUCTION: {"assembly":["GMOV <bundle operands>"],"block":["BSTART.TLSU GMOV, DataType","B.IOT source, destination, PE_MASK, TSize","B.IOR peer_tid","BSTOP"],"catalog_indices":[96],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.GMOV","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"GMOV","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_GMOV","name":"GMOV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"resolved-peer-source"},{"field":"scalar0","role":"peer-tid"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"GMOV","state_effects":["operand:destination0:destination","operand:source0:resolved-peer-source","operand:scalar0:peer-tid"]}],"classification":["memory-and-data-movement","pe-movement"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-GMOV","mnemonic":"GMOV","summary":"Copy the resolved peer-PE Tile fragment selected by the bound peer TID.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_GMOV() => TileOperation
begin
    return TileOperation_GMOV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_GMOV() => TileSemanticHandler
begin
    return TileHandler_GMOV;
end;
// DOC-END: operation
