// PTO-INSTRUCTION: {"assembly":["TMATMUL_MX_ACC <bundle operands>"],"block":["BSTART.CUBE TMATMULMX.ACC AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOS Shared operand binder (optional)","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[102],"catalog_records":[{"disposition":"accepted-direct-operation","family":"CUBE","command_mnemonic":"BSTART.TMATMULMX.ACC","function":6,"name":"TMATMUL_MX_ACC","semantic_handler":"TMATMUL_MX_ACC","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"accumulator"},{"field":"source1","role":"left"},{"field":"source2","role":"row-scale"},{"field":"source3","role":"right"},{"field":"source4","role":"column-scale"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"},{"operand":"source4"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TMATMUL_MX_ACC","effect_contract":"TMATMUL_MX_ACC","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:accumulator","operand:source1:left","operand:source2:row-scale","operand:source3:right","operand:source4:column-scale"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["matrix","matrix-matrix"],"mnemonic":"TMATMUL_MX_ACC","summary":"Multiply scaled matrices and accumulate into the supplied accumulator Tile.","surface":"tile","id":"PTO-TILE-TMATMUL-MX-ACC","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_MX_ACC() => TileOperation
begin
    return TileOperation_TMATMUL_MX_ACC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TMATMUL_MX_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_MX_ACC() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_ACC;
end;
// DOC-END: operation
