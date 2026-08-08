// PTO-INSTRUCTION: {"assembly":["TROWMAX <bundle operands>"],"block":["BSTART.TEPL TROWMAX, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[41],"catalog_records":[{"arguments":[{"constant":"TileReduction_MAX"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileReduction","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":1,"legality_handler":"TileOperandsLegal_ExecuteTileReduction","mode":2,"name":"TROWMAX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x041","semantic_handler":"ExecuteTileReduction","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["reduction","row-reduction"],"mnemonic":"TROWMAX","summary":"Execute the TROWMAX Tile operation contract.","surface":"tile","id":"PTO-TILE-TROWMAX","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWMAX() => TileOperation
begin
    return TileOperation_TROWMAX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TROWMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
// DOC-END: operation
