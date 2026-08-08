// PTO-INSTRUCTION: {"assembly":["MSCATTER <bundle operands>"],"block":["BSTART.TLSU MSCATTER, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[92],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.MSCATTER","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":5,"legality_handler":"TileOperandsLegal_MSCATTER","name":"MSCATTER","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER","state_effects":["operand:address:base-address","operand:source0:source","operand:source1:indices"]}],"classification":["memory","irregular"],"mnemonic":"MSCATTER","summary":"Execute the MSCATTER Tile operation contract.","surface":"tile","id":"PTO-TILE-MSCATTER","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MSCATTER() => TileOperation
begin
    return TileOperation_MSCATTER;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MSCATTER() => TileSemanticHandler
begin
    return TileHandler_MSCATTER;
end;
// DOC-END: operation
