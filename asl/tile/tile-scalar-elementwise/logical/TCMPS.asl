// PTO-INSTRUCTION: {"assembly":["TCMPS <bundle operands>"],"block":["BSTART.TEPL TCMPS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[37],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TCMPS","selector":"0x02D","semantic_handler":"ExecuteTileCompareScalar","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"},{"field":"comparison","role":"comparison"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"comparison"}],"mode":1,"function":13,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileCompareScalar","effect_contract":"ExecuteTileCompareScalar","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar","operand:comparison:comparison"],"datr_contract":{"allowed_nonzero_fields":["CMode"],"pad_union":"must-zero"}}],"classification":["tile-scalar-elementwise","logical"],"mnemonic":"TCMPS","summary":"Apply elementwise comparison between the source Tile and bound scalar.","surface":"tile","id":"PTO-TILE-TCMPS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCMPS() => TileOperation
begin
    return TileOperation_TCMPS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCMPS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompareScalar;
end;
// DOC-END: operation
