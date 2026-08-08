// PTO-INSTRUCTION: {"assembly":["TXOR <bundle operands>"],"block":["BSTART.TEPL TXOR, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[7],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TXOR","selector":"0x008","semantic_handler":"ExecuteTileBinary","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"arguments":[{"constant":"TileBinary_XOR"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":0,"function":8,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileBinary","effect_contract":"ExecuteTileBinary","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["tile-tile-elementwise","logical"],"mnemonic":"TXOR","summary":"Execute the TXOR Tile operation contract.","surface":"tile","id":"PTO-TILE-TXOR","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TXOR() => TileOperation
begin
    return TileOperation_TXOR;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TXOR() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;
// DOC-END: operation
