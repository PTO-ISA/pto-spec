// PTO-INSTRUCTION: {"assembly":["MSCATTER_MASK <bundle operands>"],"block":["BSTART.MSCATTER.MASK DataType","B.IOT","B.IOR base_address","BSTOP"],"catalog_indices":[94],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.MSCATTER.MASK","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER_MASK","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_MSCATTER_MASK","name":"MSCATTER_MASK","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"},{"field":"source2","role":"mask"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER_MASK","state_effects":["operand:address:base-address","operand:source0:source","operand:source1:indices","operand:source2:mask"]}],"classification":["memory","irregular"],"mnemonic":"MSCATTER_MASK","summary":"Execute the MSCATTER_MASK Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MSCATTER_MASK() => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MSCATTER_MASK() => TileSemanticHandler
begin
    return TileHandler_MSCATTER_MASK;
end;
// DOC-END: operation
