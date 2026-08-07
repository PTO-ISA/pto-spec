// PTO-INSTRUCTION: {"assembly":["TMATMUL_BIAS <bundle operands>"],"block":["BSTART.CUBE TMATMUL.BIAS AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOS Shared operand binder (optional)","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[98],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TMATMUL.BIAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMATMUL_BIAS","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":1,"legality_handler":"TileOperandsLegal_TMATMUL_BIAS","name":"TMATMUL_BIAS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"right"},{"field":"source2","role":"bias"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMATMUL_BIAS","state_effects":["operand:destination0:destination","operand:source0:left","operand:source1:right","operand:source2:bias"]}],"classification":["matrix","matrix-matrix"],"mnemonic":"TMATMUL_BIAS","summary":"Execute the TMATMUL_BIAS Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_BIAS() => TileOperation
begin
    return TileOperation_TMATMUL_BIAS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TMATMUL_BIAS_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_BIAS() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_BIAS;
end;
// DOC-END: operation
