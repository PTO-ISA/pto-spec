// PTO-INSTRUCTION: {"assembly":["TGEMV_BIAS <bundle operands>"],"block":["BSTART.CUBE TGEMV.BIAS AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[104],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TGEMV.BIAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGEMV_BIAS","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":17,"legality_handler":"TileOperandsLegal_TGEMV_BIAS","name":"TGEMV_BIAS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"matrix"},{"field":"source1","role":"vector"},{"field":"source2","role":"bias"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TGEMV_BIAS","state_effects":["operand:destination0:destination","operand:source0:matrix","operand:source1:vector","operand:source2:bias"]}],"classification":["matrix","matrix-vector"],"mnemonic":"TGEMV_BIAS","summary":"Execute the TGEMV_BIAS Tile operation contract.","surface":"tile","id":"PTO-TILE-TGEMV-BIAS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV_BIAS() => TileOperation
begin
    return TileOperation_TGEMV_BIAS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TGEMV_BIAS_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_BIAS() => TileSemanticHandler
begin
    return TileHandler_TGEMV_BIAS;
end;
// DOC-END: operation
