// PTO-INSTRUCTION: {"assembly":["TMATMUL_MX_BIAS <bundle operands>"],"block":["BSTART.CUBE TMATMULMX.BIAS AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOS Shared operand binder (optional)","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[101],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"},{"operand":"source4"}],"command_mnemonic":"BSTART.TMATMULMX.BIAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMATMUL_MX_BIAS","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":5,"legality_handler":"TileOperandsLegal_TMATMUL_MX_BIAS","name":"TMATMUL_MX_BIAS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"right"},{"field":"source3","role":"column-scale"},{"field":"source4","role":"bias"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMATMUL_MX_BIAS","state_effects":["operand:destination0:destination","operand:source0:left","operand:source1:row-scale","operand:source2:right","operand:source3:column-scale","operand:source4:bias"]}],"classification":["matrix-and-matrix-vector","matrix-matrix"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TMATMUL-MX-BIAS","mnemonic":"TMATMUL_MX_BIAS","summary":"Multiply scaled matrices and add the bias Tile.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_MX_BIAS() => TileOperation
begin
    return TileOperation_TMATMUL_MX_BIAS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
// Complete-bundle dynamic schema linkage: this static mathematical operand owner participates in the
// conditional B.FPATR schema (scalar QuantParam/LReLUParam, ordered Local
// RowMax/parameter streams, and D/auxiliary destinations) owned by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and evidenced in
// spec/evidence/bundle-command-totality.json.
readonly func InstructionContractMatrixShapeLegal_TMATMUL_MX_BIAS_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_MX_BIAS() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_BIAS;
end;
// DOC-END: operation
