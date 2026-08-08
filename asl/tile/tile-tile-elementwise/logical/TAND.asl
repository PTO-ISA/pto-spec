// PTO-INSTRUCTION: {"assembly":["TAND <bundle operands>"],"block":["BSTART.TEPL TAND, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[5],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TAND","selector":"0x006","semantic_handler":"ExecuteTileBinary","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"arguments":[{"constant":"TileBinary_AND"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":0,"function":6,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileBinary","effect_contract":"ExecuteTileBinary","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["tile-tile-elementwise","logical"],"mnemonic":"TAND","summary":"Execute the TAND Tile operation contract.","surface":"tile","id":"PTO-TILE-TAND","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
