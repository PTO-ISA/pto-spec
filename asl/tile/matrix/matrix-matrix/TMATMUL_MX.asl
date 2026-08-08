// PTO-INSTRUCTION: {"assembly":["TMATMUL_MX <bundle operands>"],"block":["BSTART.CUBE TMATMULMX AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOS Shared operand binder (optional)","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[100],"catalog_records":[{"disposition":"accepted-direct-operation","family":"CUBE","command_mnemonic":"BSTART.TMATMULMX","function":4,"name":"TMATMUL_MX","semantic_handler":"TMATMUL_MX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"right"},{"field":"source3","role":"column-scale"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TMATMUL_MX","effect_contract":"TMATMUL_MX","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:left","operand:source1:row-scale","operand:source2:right","operand:source3:column-scale"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["matrix","matrix-matrix"],"mnemonic":"TMATMUL_MX","summary":"Execute the TMATMUL_MX Tile operation contract.","surface":"tile","id":"PTO-TILE-TMATMUL-MX","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_MX() => TileOperation
begin
    return TileOperation_TMATMUL_MX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TMATMUL_MX_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_MX() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX;
end;
// DOC-END: operation
