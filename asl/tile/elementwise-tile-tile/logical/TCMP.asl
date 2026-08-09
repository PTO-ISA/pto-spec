// PTO-INSTRUCTION: {"assembly":["TCMP <bundle operands>"],"block":["BSTART.VEC TCMP, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[12],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"comparison"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["CMode"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileCompare","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_ExecuteTileCompare","mode":0,"name":"TCMP","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"},{"field":"comparison","role":"comparison"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x00D","semantic_handler":"ExecuteTileCompare","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right","operand:comparison:comparison"]}],"classification":["elementwise-tile-tile","logical"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TCMP","mnemonic":"TCMP","summary":"Apply elementwise comparison to the two source Tiles.","surface":"tile"}
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
