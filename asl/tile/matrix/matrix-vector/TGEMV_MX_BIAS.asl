// PTO-INSTRUCTION: {"assembly":["TGEMV_MX_BIAS <bundle operands>"],"block":["BSTART.CUBE TGEMVMX.BIAS AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[107],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"},{"operand":"source4"}],"command_mnemonic":"BSTART.TGEMVMX.BIAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGEMV_MX_BIAS","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":21,"legality_handler":"TileOperandsLegal_TGEMV_MX_BIAS","name":"TGEMV_MX_BIAS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"matrix"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"vector"},{"field":"source3","role":"column-scale"},{"field":"source4","role":"bias"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TGEMV_MX_BIAS","state_effects":["operand:destination0:destination","operand:source0:matrix","operand:source1:row-scale","operand:source2:vector","operand:source3:column-scale","operand:source4:bias"]}],"classification":["matrix","matrix-vector"],"mnemonic":"TGEMV_MX_BIAS","summary":"Execute the TGEMV_MX_BIAS Tile operation contract.","surface":"tile","id":"PTO-TILE-TGEMV-MX-BIAS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV_MX_BIAS() => TileOperation
begin
    return TileOperation_TGEMV_MX_BIAS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TGEMV_MX_BIAS_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_MX_BIAS() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX_BIAS;
end;
// DOC-END: operation
