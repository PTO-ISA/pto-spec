// PTO-INSTRUCTION: {"assembly":["MSCATTER <bundle operands>"],"block":["BSTART.TLSU MSCATTER, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[92],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.MSCATTER","function":5,"name":"MSCATTER","semantic_handler":"MSCATTER","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"}],"arguments":[{"operand":"address"},{"operand":"source0"},{"operand":"source1"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_MSCATTER","effect_contract":"MSCATTER","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:address:base-address","operand:source0:source","operand:source1:indices"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["memory","irregular"],"mnemonic":"MSCATTER","summary":"Scatter source Tile elements to GM addresses selected by Tile indices.","surface":"tile","id":"PTO-TILE-MSCATTER","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
