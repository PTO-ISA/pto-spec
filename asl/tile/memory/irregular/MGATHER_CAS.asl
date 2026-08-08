// PTO-INSTRUCTION: {"assembly":["MGATHER_CAS <bundle operands>"],"block":["BSTART.MGATHER.CAS DataType","B.IOT","B.IOR base_address","BSTOP"],"catalog_indices":[95],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.MGATHER.CAS","function":8,"name":"MGATHER_CAS","semantic_handler":"MGATHER_CAS","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"},{"field":"source1","role":"expected"},{"field":"source2","role":"replacement"}],"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_MGATHER_CAS","effect_contract":"MGATHER_CAS","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:indices","operand:source1:expected","operand:source2:replacement"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["memory","irregular"],"mnemonic":"MGATHER_CAS","summary":"Execute the MGATHER_CAS Tile operation contract.","surface":"tile","id":"PTO-TILE-MGATHER-CAS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
