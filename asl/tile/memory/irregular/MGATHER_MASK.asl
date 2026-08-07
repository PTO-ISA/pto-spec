// PTO-INSTRUCTION: {"assembly":["MGATHER_MASK <bundle operands>"],"block":["BSTART.MGATHER.MASK DataType","B.DATR PadValue (optional)","B.IOT","B.IOR base_address","BSTOP"],"catalog_indices":[93],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.MGATHER.MASK","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER_MASK","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_MGATHER_MASK","name":"MGATHER_MASK","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"},{"field":"source1","role":"mask"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER_MASK","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:indices","operand:source1:mask"]}],"classification":["memory","irregular"],"mnemonic":"MGATHER_MASK","summary":"Execute the MGATHER_MASK Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MGATHER_MASK() => TileOperation
begin
    return TileOperation_MGATHER_MASK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MGATHER_MASK() => TileSemanticHandler
begin
    return TileHandler_MGATHER_MASK;
end;
// DOC-END: operation
