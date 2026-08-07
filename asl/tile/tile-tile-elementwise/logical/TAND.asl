// PTO-INSTRUCTION: {"assembly":["TAND <bundle operands>"],"block":["BSTART.TEPL TAND, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[5],"catalog_records":[{"arguments":[{"constant":"TileBinary_AND"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TAND","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x006","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["tile-tile-elementwise","logical"],"mnemonic":"TAND","summary":"Execute the TAND Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TAND() => TileOperation
begin
    return TileOperation_TAND;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TAND() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;
// DOC-END: operation
