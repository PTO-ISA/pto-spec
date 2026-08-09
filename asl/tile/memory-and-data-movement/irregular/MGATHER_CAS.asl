// PTO-INSTRUCTION: {"assembly":["MGATHER_CAS <bundle operands>"],"block":["BSTART.MGATHER.CAS DataType","B.IOT","B.IOR base_address","BSTOP"],"catalog_indices":[95],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.MGATHER.CAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER_CAS","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":8,"legality_handler":"TileOperandsLegal_MGATHER_CAS","name":"MGATHER_CAS","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"},{"field":"source1","role":"expected"},{"field":"source2","role":"replacement"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER_CAS","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:indices","operand:source1:expected","operand:source2:replacement"]}],"classification":["memory-and-data-movement","irregular"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MGATHER-CAS","mnemonic":"MGATHER_CAS","summary":"Atomically compare and conditionally replace GM elements at Tile-provided indices.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_MGATHER_CAS;
end;
// DOC-END: operation
