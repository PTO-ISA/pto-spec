// PTO-INSTRUCTION: {"assembly":["TDIV <bundle operands>"],"block":["BSTART.TEPL TDIV, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[3],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TDIV","selector":"0x003","semantic_handler":"ExecuteTileBinary","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"arguments":[{"constant":"TileBinary_DIV"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":0,"function":3,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileBinary","effect_contract":"ExecuteTileBinary","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["unary-tile-elementwise","transcendental"],"mnemonic":"TDIV","summary":"Apply elementwise division to the two source Tiles.","surface":"tile","id":"PTO-TILE-TDIV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TDIV() => TileOperation
begin
    return TileOperation_TDIV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;
// DOC-END: operation
