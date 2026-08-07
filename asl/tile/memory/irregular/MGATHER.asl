// PTO-INSTRUCTION: {"assembly":["MGATHER <bundle operands>"],"block":["BSTART.TLSU MGATHER, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[91],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"}],"command_mnemonic":"BSTART.MGATHER","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":4,"legality_handler":"TileOperandsLegal_MGATHER","name":"MGATHER","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:indices"]}],"classification":["memory","irregular"],"mnemonic":"MGATHER","summary":"Execute the MGATHER Tile operation contract.","surface":"tile"}
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
