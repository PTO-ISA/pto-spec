// PTO-INSTRUCTION: {"assembly":["TEXPANDS <bundle operands>"],"block":["BSTART.TEPL TEXPANDS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[39],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileFillScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":27,"legality_handler":"TileOperandsLegal_ExecuteTileFillScalar","mode":1,"name":"TEXPANDS","operands":[{"field":"destination0","role":"destination"},{"field":"scalar0","role":"scalar"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x03B","semantic_handler":"ExecuteTileFillScalar","state_effects":["operand:destination0:destination","operand:scalar0:scalar"]}],"classification":["complex-layout","initialization"],"mnemonic":"TEXPANDS","summary":"Execute the TEXPANDS Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TEXPANDS() => TileOperation
begin
    return TileOperation_TEXPANDS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TEXPANDS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileFillScalar;
end;
// DOC-END: operation
