// PTO-INSTRUCTION: {"assembly":["TCMP <bundle operands>"],"block":["BSTART.TEPL TCMP, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[12],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TCMP","selector":"0x00D","semantic_handler":"ExecuteTileCompare","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"},{"field":"comparison","role":"comparison"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"comparison"}],"mode":0,"function":13,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileCompare","effect_contract":"ExecuteTileCompare","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right","operand:comparison:comparison"],"datr_contract":{"allowed_nonzero_fields":["CMode"],"pad_union":"must-zero"}}],"classification":["tile-tile-elementwise","logical"],"mnemonic":"TCMP","summary":"Apply elementwise comparison to the two source Tiles.","surface":"tile","id":"PTO-TILE-TCMP","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCMP() => TileOperation
begin
    return TileOperation_TCMP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCMP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompare;
end;
// DOC-END: operation
