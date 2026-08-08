// PTO-INSTRUCTION: {"assembly":["TTRANS <bundle operands>"],"block":["BSTART.TEPL TTRANS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[80],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TTRANS","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":14,"legality_handler":"TileOperandsLegal_TTRANS","mode":3,"name":"TTRANS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06E","semantic_handler":"TTRANS","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["complex-layout","layout"],"mnemonic":"TTRANS","summary":"Execute the TTRANS Tile operation contract.","surface":"tile","id":"PTO-TILE-TTRANS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
