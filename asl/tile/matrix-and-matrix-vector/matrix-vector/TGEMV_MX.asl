// PTO-INSTRUCTION: {"assembly":["TGEMV_MX <bundle operands>"],"block":["BSTART.CUBE TGEMVMX AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[106],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"}],"command_mnemonic":"BSTART.TGEMVMX","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGEMV_MX","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":20,"legality_handler":"TileOperandsLegal_TGEMV_MX","name":"TGEMV_MX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"matrix"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"vector"},{"field":"source3","role":"column-scale"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TGEMV_MX","state_effects":["operand:destination0:destination","operand:source0:matrix","operand:source1:row-scale","operand:source2:vector","operand:source3:column-scale"]}],"classification":["matrix-and-matrix-vector","matrix-vector"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TGEMV-MX","mnemonic":"TGEMV_MX","summary":"Multiply the matrix by the vector using row and column scale Tiles.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV_MX() => TileOperation
begin
    return TileOperation_TGEMV_MX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
// Complete-bundle dynamic schema linkage: this static mathematical operand owner participates in the
// conditional B.FPATR schema (scalar QuantParam/LReLUParam, ordered Local
// RowMax/parameter streams, and D/auxiliary destinations) owned by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and evidenced in
// spec/evidence/bundle-command-totality.json.
readonly func InstructionContractMatrixShapeLegal_TGEMV_MX_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_MX() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX;
end;
// DOC-END: operation
