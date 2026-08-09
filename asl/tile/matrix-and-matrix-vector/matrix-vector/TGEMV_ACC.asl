// PTO-INSTRUCTION: {"assembly":["TGEMV_ACC <bundle operands>"],"block":["BSTART.CUBE TGEMV.ACC AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[105],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TGEMV.ACC","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGEMV_ACC","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":18,"legality_handler":"TileOperandsLegal_TGEMV_ACC","name":"TGEMV_ACC","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"accumulator"},{"field":"source1","role":"matrix"},{"field":"source2","role":"vector"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TGEMV_ACC","state_effects":["operand:destination0:destination","operand:source0:accumulator","operand:source1:matrix","operand:source2:vector"]}],"classification":["matrix-and-matrix-vector","matrix-vector"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TGEMV-ACC","mnemonic":"TGEMV_ACC","summary":"Multiply the matrix by the vector and accumulate into the supplied Tile.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV_ACC() => TileOperation
begin
    return TileOperation_TGEMV_ACC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TGEMV_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_ACC() => TileSemanticHandler
begin
    return TileHandler_TGEMV_ACC;
end;
// DOC-END: operation
