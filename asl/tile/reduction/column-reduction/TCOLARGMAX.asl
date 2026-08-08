// PTO-INSTRUCTION: {"assembly":["TCOLARGMAX <bundle operands>"],"block":["BSTART.TEPL TCOLARGMAX, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[66],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TCOLARGMAX","selector":"0x05C","semantic_handler":"ExecuteTileReduction","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"arguments":[{"constant":"TileReduction_ARGMAX"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"}],"mode":2,"function":28,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileReduction","effect_contract":"ExecuteTileReduction","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["reduction","column-reduction"],"mnemonic":"TCOLARGMAX","summary":"Execute the TCOLARGMAX Tile operation contract.","surface":"tile","id":"PTO-TILE-TCOLARGMAX","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLARGMAX() => TileOperation
begin
    return TileOperation_TCOLARGMAX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCOLARGMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
// DOC-END: operation
