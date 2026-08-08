// PTO-INSTRUCTION: {"assembly":["TTRANS <bundle operands>"],"block":["BSTART.TEPL TTRANS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[80],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TTRANS","selector":"0x06E","semantic_handler":"TTRANS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"arguments":[{"operand":"destination0"},{"operand":"source0"}],"mode":3,"function":14,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TTRANS","effect_contract":"TTRANS","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","layout"],"mnemonic":"TTRANS","summary":"Transpose the source Tile into the destination.","surface":"tile","id":"PTO-TILE-TTRANS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TTRANS() => TileOperation
begin
    return TileOperation_TTRANS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TTRANS() => TileSemanticHandler
begin
    return TileHandler_TTRANS;
end;
// DOC-END: operation
