// PTO-INSTRUCTION: {"assembly":["TGEMV_MX_ACC <bundle operands>"],"block":["BSTART.CUBE TGEMVMX.ACC AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 M","B.DIM LB1 N","B.DIM LB2 K","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[108],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"},{"operand":"source4"}],"command_mnemonic":"BSTART.TGEMVMX.ACC","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGEMV_MX_ACC","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":22,"legality_handler":"TileOperandsLegal_TGEMV_MX_ACC","name":"TGEMV_MX_ACC","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"accumulator"},{"field":"source1","role":"matrix"},{"field":"source2","role":"row-scale"},{"field":"source3","role":"vector"},{"field":"source4","role":"column-scale"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TGEMV_MX_ACC","state_effects":["operand:destination0:destination","operand:source0:accumulator","operand:source1:matrix","operand:source2:row-scale","operand:source3:vector","operand:source4:column-scale"]}],"classification":["matrix","matrix-vector"],"mnemonic":"TGEMV_MX_ACC","summary":"Execute the TGEMV_MX_ACC Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV_MX_ACC() => TileOperation
begin
    return TileOperation_TGEMV_MX_ACC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TGEMV_MX_ACC() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX_ACC;
end;
// DOC-END: operation
