// PTO-INSTRUCTION: {"assembly":["TOR <bundle operands>"],"block":["BSTART.VEC TOR, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[6],"catalog_records":[{"arguments":[{"constant":"TileBinary_OR"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TOR","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x007","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["elementwise-tile-tile","logical"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TOR","mnemonic":"TOR","summary":"Apply elementwise bitwise OR to the two source Tiles.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TOR() => TileOperation
begin
    return TileOperation_TOR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TOR() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;
// DOC-END: operation
