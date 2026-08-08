// PTO-INSTRUCTION: {"assembly":["TGEMV_MX_ACC <bundle operands>"],"block":["BSTART.CUBE TGEMVMX.ACC AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[108],"catalog_records":[{"disposition":"accepted-direct-operation","family":"CUBE","command_mnemonic":"BSTART.TGEMVMX.ACC","function":22,"name":"TGEMV_MX_ACC","semantic_handler":"TGEMV_MX_ACC","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"accumulator"},{"field":"source1","role":"matrix"},{"field":"source2","role":"row-scale"},{"field":"source3","role":"vector"},{"field":"source4","role":"column-scale"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"},{"operand":"source4"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TGEMV_MX_ACC","effect_contract":"TGEMV_MX_ACC","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:accumulator","operand:source1:matrix","operand:source2:row-scale","operand:source3:vector","operand:source4:column-scale"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["matrix","matrix-vector"],"mnemonic":"TGEMV_MX_ACC","summary":"Execute the TGEMV_MX_ACC Tile operation contract.","surface":"tile","id":"PTO-TILE-TGEMV-MX-ACC","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV_MX_ACC() => TileOperation
begin
    return TileOperation_TGEMV_MX_ACC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TGEMV_MX_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_MX_ACC() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX_ACC;
end;
// DOC-END: operation
