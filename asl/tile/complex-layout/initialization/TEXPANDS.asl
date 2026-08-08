// PTO-INSTRUCTION: {"assembly":["TEXPANDS <bundle operands>"],"block":["BSTART.TEPL TEXPANDS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[39],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TEXPANDS","selector":"0x03B","semantic_handler":"ExecuteTileFillScalar","operands":[{"field":"destination0","role":"destination"},{"field":"scalar0","role":"scalar"}],"arguments":[{"operand":"destination0"},{"operand":"scalar0"}],"mode":1,"function":27,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileFillScalar","effect_contract":"ExecuteTileFillScalar","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:scalar0:scalar"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["complex-layout","initialization"],"mnemonic":"TEXPANDS","summary":"Fill the destination Tile by expanding the bound scalar value.","surface":"tile","id":"PTO-TILE-TEXPANDS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TEXPANDS() => TileOperation
begin
    return TileOperation_TEXPANDS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TEXPANDS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileFillScalar;
end;
// DOC-END: operation
