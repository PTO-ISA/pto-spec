// PTO-INSTRUCTION: {"assembly":["TPREFETCH <bundle operands>"],"block":["BSTART.TLSU TPREFETCH, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[90],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.TPREFETCH","function":3,"name":"TPREFETCH","semantic_handler":"TPREFETCH","operands":[{"field":"address","role":"base-address"},{"field":"byte_count","role":"byte-count"}],"arguments":[{"operand":"address"},{"operand":"byte_count"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TPREFETCH","effect_contract":"TPREFETCH","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:address:base-address","operand:byte_count:byte-count"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["memory","regular"],"mnemonic":"TPREFETCH","summary":"Prefetch the requested GM byte range without producing a Tile destination.","surface":"tile","id":"PTO-TILE-TPREFETCH","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPREFETCH() => TileOperation
begin
    return TileOperation_TPREFETCH;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TPREFETCH() => TileSemanticHandler
begin
    return TileHandler_TPREFETCH;
end;
// DOC-END: operation
