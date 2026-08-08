// PTO-INSTRUCTION: {"assembly":["MSCATTER_MASK <bundle operands>"],"block":["BSTART.MSCATTER.MASK DataType","B.IOT","B.IOR base_address","BSTOP"],"catalog_indices":[94],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.MSCATTER.MASK","function":7,"name":"MSCATTER_MASK","semantic_handler":"MSCATTER_MASK","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"},{"field":"source2","role":"mask"}],"arguments":[{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_MSCATTER_MASK","effect_contract":"MSCATTER_MASK","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:address:base-address","operand:source0:source","operand:source1:indices","operand:source2:mask"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["memory","irregular"],"mnemonic":"MSCATTER_MASK","summary":"Execute the MSCATTER_MASK Tile operation contract.","surface":"tile","id":"PTO-TILE-MSCATTER-MASK","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
