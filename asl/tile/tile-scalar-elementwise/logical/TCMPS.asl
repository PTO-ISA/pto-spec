// PTO-INSTRUCTION: {"assembly":["TCMPS <bundle operands>"],"block":["BSTART.TEPL TCMPS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[37],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"comparison"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["CMode"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileCompareScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_ExecuteTileCompareScalar","mode":1,"name":"TCMPS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"},{"field":"comparison","role":"comparison"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x02D","semantic_handler":"ExecuteTileCompareScalar","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar","operand:comparison:comparison"]}],"classification":["tile-scalar-elementwise","logical"],"mnemonic":"TCMPS","summary":"Execute the TCMPS Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCMPS() => TileOperation
begin
    return TileOperation_TCMPS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCMPS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompareScalar;
end;
// DOC-END: operation
