// PTO-INSTRUCTION: {"assembly":["TMATMUL_ACC <bundle operands>"],"block":["BSTART.CUBE TMATMUL.ACC AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOS Shared operand binder (optional)","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[99],"catalog_records":[{"disposition":"accepted-direct-operation","family":"CUBE","command_mnemonic":"BSTART.TMATMUL.ACC","function":2,"name":"TMATMUL_ACC","semantic_handler":"TMATMUL_ACC","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"accumulator"},{"field":"source1","role":"left"},{"field":"source2","role":"right"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TMATMUL_ACC","effect_contract":"TMATMUL_ACC","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:accumulator","operand:source1:left","operand:source2:right"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["matrix","matrix-matrix"],"mnemonic":"TMATMUL_ACC","summary":"Execute the TMATMUL_ACC Tile operation contract.","surface":"tile","id":"PTO-TILE-TMATMUL-ACC","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_ACC() => TileOperation
begin
    return TileOperation_TMATMUL_ACC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TMATMUL_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_ACC() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_ACC;
end;
// DOC-END: operation
