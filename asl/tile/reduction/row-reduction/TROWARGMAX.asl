// PTO-INSTRUCTION: {"assembly":["TROWARGMAX <bundle operands>"],"block":["BSTART.TEPL TROWARGMAX, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[52],"catalog_records":[{"arguments":[{"constant":"TileReduction_ARGMAX"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileReduction","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":12,"legality_handler":"TileOperandsLegal_ExecuteTileReduction","mode":2,"name":"TROWARGMAX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x04C","semantic_handler":"ExecuteTileReduction","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["reduction","row-reduction"],"mnemonic":"TROWARGMAX","summary":"Execute the TROWARGMAX Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWARGMAX() => TileOperation
begin
    return TileOperation_TROWARGMAX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TROWARGMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
// DOC-END: operation
