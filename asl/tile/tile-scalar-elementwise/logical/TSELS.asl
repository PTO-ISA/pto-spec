// PTO-INSTRUCTION: {"assembly":["TSELS <bundle operands>"],"block":["BSTART.TEPL TSELS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[38],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileSelectScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":26,"legality_handler":"TileOperandsLegal_ExecuteTileSelectScalar","mode":1,"name":"TSELS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"mask"},{"field":"source1","role":"source-true"},{"field":"scalar0","role":"scalar-false"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x03A","semantic_handler":"ExecuteTileSelectScalar","state_effects":["operand:destination0:destination","operand:source0:mask","operand:source1:source-true","operand:scalar0:scalar-false"]}],"classification":["tile-scalar-elementwise","logical"],"mnemonic":"TSELS","summary":"Execute the TSELS Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSELS() => TileOperation
begin
    return TileOperation_TSELS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSELS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelectScalar;
end;
// DOC-END: operation
