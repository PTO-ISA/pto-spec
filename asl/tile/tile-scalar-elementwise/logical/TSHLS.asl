// PTO-INSTRUCTION: {"assembly":["TSHLS <bundle operands>"],"block":["BSTART.TEPL TSHLS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[33],"catalog_records":[{"arguments":[{"constant":"TileBinary_SHL"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":9,"legality_handler":"TileOperandsLegal_ExecuteTileScalar","mode":1,"name":"TSHLS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x029","semantic_handler":"ExecuteTileScalar","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar"]}],"classification":["tile-scalar-elementwise","logical"],"mnemonic":"TSHLS","summary":"Execute the TSHLS Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSHLS() => TileOperation
begin
    return TileOperation_TSHLS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSHLS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
// DOC-END: operation
