// PTO-INSTRUCTION: {"assembly":["TCOLARGMIN <bundle operands>"],"block":["BSTART.TEPL TCOLARGMIN, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[67],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TCOLARGMIN","selector":"0x05D","semantic_handler":"ExecuteTileReduction","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"arguments":[{"constant":"TileReduction_ARGMIN"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"}],"mode":2,"function":29,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileReduction","effect_contract":"ExecuteTileReduction","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["reduction","column-reduction"],"mnemonic":"TCOLARGMIN","summary":"Reduce each source col to its minimum index.","surface":"tile","id":"PTO-TILE-TCOLARGMIN","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
