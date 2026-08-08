// PTO-INSTRUCTION: {"assembly":["TPARTMIN <bundle operands>"],"block":["BSTART.TEPL TPARTMIN, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[86],"catalog_records":[{"arguments":[{"constant":"TilePartial_MIN"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTilePartial","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":20,"legality_handler":"TileOperandsLegal_ExecuteTilePartial","mode":3,"name":"TPARTMIN","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x074","semantic_handler":"ExecuteTilePartial","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["complex-layout","union"],"mnemonic":"TPARTMIN","summary":"Execute the TPARTMIN Tile operation contract.","surface":"tile","id":"PTO-TILE-TPARTMIN","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
