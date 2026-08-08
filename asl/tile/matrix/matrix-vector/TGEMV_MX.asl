// PTO-INSTRUCTION: {"assembly":["TGEMV_MX <bundle operands>"],"block":["BSTART.CUBE TGEMVMX AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[106],"catalog_records":[{"disposition":"accepted-direct-operation","family":"CUBE","command_mnemonic":"BSTART.TGEMVMX","function":20,"name":"TGEMV_MX","semantic_handler":"TGEMV_MX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"matrix"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"vector"},{"field":"source3","role":"column-scale"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TGEMV_MX","effect_contract":"TGEMV_MX","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:matrix","operand:source1:row-scale","operand:source2:vector","operand:source3:column-scale"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["matrix","matrix-vector"],"mnemonic":"TGEMV_MX","summary":"Multiply the matrix by the vector using row and column scale Tiles.","surface":"tile","id":"PTO-TILE-TGEMV-MX","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV_MX() => TileOperation
begin
    return TileOperation_TGEMV_MX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TGEMV_MX_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_MX() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX;
end;
// DOC-END: operation
