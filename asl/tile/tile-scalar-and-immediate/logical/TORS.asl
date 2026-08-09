// PTO-INSTRUCTION: {"assembly":["TORS <bundle operands>"],"block":["BSTART.VEC TORS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[31],"catalog_records":[{"arguments":[{"constant":"TileBinary_OR"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_ExecuteTileScalar","mode":1,"name":"TORS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x027","semantic_handler":"ExecuteTileScalar","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar"]}],"classification":["tile-scalar-and-immediate","logical"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TORS","mnemonic":"TORS","summary":"Apply elementwise bitwise OR between the source Tile and bound scalar.","surface":"tile"}
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
