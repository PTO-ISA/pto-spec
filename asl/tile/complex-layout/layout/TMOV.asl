// PTO-INSTRUCTION: {"assembly":["TMOV <bundle operands>"],"block":["BSTART.TLSU TMOV, DataType","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[89],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TLSU","command_mnemonic":"BSTART.TMOV","function":2,"name":"TMOV","semantic_handler":"TMOV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"arguments":[{"operand":"destination0"},{"operand":"source0"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TMOV","effect_contract":"TMOV","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","layout"],"mnemonic":"TMOV","summary":"Execute the TMOV Tile operation contract.","surface":"tile","id":"PTO-TILE-TMOV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMOV() => TileOperation
begin
    return TileOperation_TMOV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TMOV() => TileSemanticHandler
begin
    return TileHandler_TMOV;
end;
// DOC-END: operation
