// PTO-INSTRUCTION: {"assembly":["TMATMUL_ACC <bundle operands>"],"block":["BSTART.CUBE TMATMUL.ACC AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOS Shared operand binder (optional)","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[99],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TMATMUL.ACC","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMATMUL_ACC","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":2,"legality_handler":"TileOperandsLegal_TMATMUL_ACC","name":"TMATMUL_ACC","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"accumulator"},{"field":"source1","role":"left"},{"field":"source2","role":"right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMATMUL_ACC","state_effects":["operand:destination0:destination","operand:source0:accumulator","operand:source1:left","operand:source2:right"]}],"classification":["matrix-and-matrix-vector","matrix-matrix"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TMATMUL-ACC","mnemonic":"TMATMUL_ACC","summary":"Multiply matrices and accumulate into the supplied accumulator Tile.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_ACC() => TileOperation
begin
    return TileOperation_TMATMUL_ACC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
// Complete-bundle dynamic schema linkage: this static mathematical operand owner participates in the
// conditional B.FPATR schema (scalar QuantParam/LReLUParam, ordered Local
// RowMax/parameter streams, and D/auxiliary destinations) owned by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and evidenced in
// spec/evidence/bundle-command-totality.json.
readonly func InstructionContractMatrixShapeLegal_TMATMUL_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_ACC() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_ACC;
end;
// DOC-END: operation
