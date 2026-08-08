// PTO-INSTRUCTION: {"assembly":["TROWMAX <bundle operands>"],"block":["BSTART.TEPL TROWMAX, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[41],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TROWMAX","selector":"0x041","semantic_handler":"ExecuteTileReduction","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"arguments":[{"constant":"TileReduction_MAX"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"}],"mode":2,"function":1,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileReduction","effect_contract":"ExecuteTileReduction","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["reduction","row-reduction"],"mnemonic":"TROWMAX","summary":"Execute the TROWMAX Tile operation contract.","surface":"tile","id":"PTO-TILE-TROWMAX","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
