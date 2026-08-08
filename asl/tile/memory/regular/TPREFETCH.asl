// PTO-INSTRUCTION: {"assembly":["TPREFETCH <bundle operands>"],"block":["BSTART.TLSU TPREFETCH, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[90],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"byte_count"}],"command_mnemonic":"BSTART.TPREFETCH","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TPREFETCH","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":3,"legality_handler":"TileOperandsLegal_TPREFETCH","name":"TPREFETCH","operands":[{"field":"address","role":"base-address"},{"field":"byte_count","role":"byte-count"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TPREFETCH","state_effects":["operand:address:base-address","operand:byte_count:byte-count"]}],"classification":["memory","regular"],"mnemonic":"TPREFETCH","summary":"Execute the TPREFETCH Tile operation contract.","surface":"tile","id":"PTO-TILE-TPREFETCH","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
