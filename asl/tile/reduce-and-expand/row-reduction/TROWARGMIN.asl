// PTO-INSTRUCTION: {"assembly":["TROWARGMIN <bundle operands>"],"block":["BSTART.SFU TROWARGMIN, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[53],"catalog_records":[{"arguments":[{"constant":"TileReduction_ARGMIN"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileReduction","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_ExecuteTileReduction","mode":2,"name":"TROWARGMIN","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x04D","semantic_handler":"ExecuteTileReduction","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["reduce-and-expand","row-reduction"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TROWARGMIN","mnemonic":"TROWARGMIN","summary":"Reduce each source row to its minimum index.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWARGMIN() => TileOperation
begin
    return TileOperation_TROWARGMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TROWARGMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
// DOC-END: operation
