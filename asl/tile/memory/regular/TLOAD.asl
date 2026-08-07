// PTO-INSTRUCTION: {"assembly":["TLOAD <bundle operands>"],"block":["# Local form","BSTART.TLSU TLOAD","B.DATR/B.DIM","B.IOT","B.IOR","BSTOP","# Shared form","BSTART.TLSU TLOAD","B.DATR/B.DIM","B.IOS","B.IOR","BSTOP"],"catalog_indices":[87],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TLOAD","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TLOAD","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":0,"legality_handler":"TileOperandsLegal_TLOAD","name":"TLOAD","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-elements"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TLOAD","state_effects":["operand:destination0:destination","operand:address:base-address","operand:scalar0:row-stride-elements"]}],"classification":["memory","regular"],"mnemonic":"TLOAD","summary":"Execute the TLOAD Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLOAD() => TileOperation
begin
    return TileOperation_TLOAD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TLOAD() => TileSemanticHandler
begin
    return TileHandler_TLOAD;
end;
// DOC-END: operation
