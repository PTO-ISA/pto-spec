// PTO-INSTRUCTION: {"assembly":["TORS <bundle operands>"],"block":["BSTART.TEPL TORS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[31],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TORS","selector":"0x027","semantic_handler":"ExecuteTileScalar","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"}],"arguments":[{"constant":"TileBinary_OR"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"mode":1,"function":7,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileScalar","effect_contract":"ExecuteTileScalar","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["tile-scalar-elementwise","logical"],"mnemonic":"TORS","summary":"Apply elementwise bitwise OR between the source Tile and bound scalar.","surface":"tile","id":"PTO-TILE-TORS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TORS() => TileOperation
begin
    return TileOperation_TORS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TORS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
// DOC-END: operation
