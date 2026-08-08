// PTO-INSTRUCTION: {"assembly":["TPARTMIN <bundle operands>"],"block":["BSTART.TEPL TPARTMIN, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[86],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TPARTMIN","selector":"0x074","semantic_handler":"ExecuteTilePartial","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"arguments":[{"constant":"TilePartial_MIN"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":3,"function":20,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTilePartial","effect_contract":"ExecuteTilePartial","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["complex-layout","union"],"mnemonic":"TPARTMIN","summary":"Execute the TPARTMIN Tile operation contract.","surface":"tile","id":"PTO-TILE-TPARTMIN","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPARTMIN() => TileOperation
begin
    return TileOperation_TPARTMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TPARTMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;
// DOC-END: operation
