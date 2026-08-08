// PTO-INSTRUCTION: {"assembly":["TSTORE <bundle operands>"],"block":["# Local form","BSTART.TLSU TSTORE","B.DATR/B.DIM","B.IOT","B.IOR","BSTOP","# Shared full form","BSTART.TLSU Function 1","B.IOS","B.IOR","BSTOP","# Shared pe_scope form","BSTART.TLSU Function 14","B.IOS","B.IOR","BSTOP"],"catalog_indices":[88],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TSTORE","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TSTORE","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":1,"legality_handler":"TileOperandsLegal_TSTORE","name":"TSTORE","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-elements"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TSTORE","state_effects":["operand:address:base-address","operand:scalar0:row-stride-elements","operand:source0:source"]}],"classification":["memory","regular"],"mnemonic":"TSTORE","summary":"Execute the TSTORE Tile operation contract.","surface":"tile","id":"PTO-TILE-TSTORE","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSTORE() => TileOperation
begin
    return TileOperation_TSTORE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;
// DOC-END: operation
