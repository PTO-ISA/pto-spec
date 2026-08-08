// PTO-INSTRUCTION: {"assembly":["TTRI <bundle operands>"],"block":["BSTART.TEPL TTRI, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[74],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TTRI","selector":"0x067","semantic_handler":"TTRI","operands":[{"field":"destination0","role":"destination"},{"field":"flag0","role":"upper"},{"field":"diagonal","role":"diagonal"}],"arguments":[{"operand":"destination0"},{"operand":"flag0"},{"operand":"diagonal"}],"mode":3,"function":7,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TTRI","effect_contract":"TTRI","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:flag0:upper","operand:diagonal:diagonal"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["complex-layout","initialization"],"mnemonic":"TTRI","summary":"Execute the TTRI Tile operation contract.","surface":"tile","id":"PTO-TILE-TTRI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TTRI() => TileOperation
begin
    return TileOperation_TTRI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TTRI() => TileSemanticHandler
begin
    return TileHandler_TTRI;
end;
// DOC-END: operation
