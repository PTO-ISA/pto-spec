// PTO-INSTRUCTION: {"assembly":["GMOV <bundle operands>"],"block":["BSTART.TLSU GMOV, DataType","B.IOT source, destination, PE_MASK, TSize","B.IOR peer_tid","BSTOP"],"catalog_indices":[96],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.GMOV","name":"GMOV","semantic_handler":"GMOV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"resolved-peer-source"},{"field":"scalar0","role":"peer-tid"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_GMOV","effect_contract":"GMOV","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:resolved-peer-source","operand:scalar0:peer-tid"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"function":13}],"classification":["memory","pe-movement"],"mnemonic":"GMOV","summary":"Execute the GMOV Tile operation contract.","surface":"tile","id":"PTO-TILE-GMOV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
