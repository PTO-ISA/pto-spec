// PTO-INSTRUCTION: {"assembly":["MGATHER <bundle operands>"],"block":["BSTART.TLSU MGATHER, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[91],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.MGATHER","function":4,"name":"MGATHER","semantic_handler":"MGATHER","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"}],"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_MGATHER","effect_contract":"MGATHER","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:indices"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["memory","irregular"],"mnemonic":"MGATHER","summary":"Execute the MGATHER Tile operation contract.","surface":"tile","id":"PTO-TILE-MGATHER","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MGATHER() => TileOperation
begin
    return TileOperation_MGATHER;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MGATHER() => TileSemanticHandler
begin
    return TileHandler_MGATHER;
end;
// DOC-END: operation
