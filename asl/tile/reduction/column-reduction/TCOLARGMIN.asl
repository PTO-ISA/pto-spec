// PTO-INSTRUCTION: {"assembly":["TCOLARGMIN <bundle operands>"],"block":["BSTART.TEPL TCOLARGMIN, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[67],"catalog_records":[{"arguments":[{"constant":"TileReduction_ARGMIN"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileReduction","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":29,"legality_handler":"TileOperandsLegal_ExecuteTileReduction","mode":2,"name":"TCOLARGMIN","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x05D","semantic_handler":"ExecuteTileReduction","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["reduction","column-reduction"],"mnemonic":"TCOLARGMIN","summary":"Execute the TCOLARGMIN Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLARGMIN() => TileOperation
begin
    return TileOperation_TCOLARGMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCOLARGMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
// DOC-END: operation
