// PTO-INSTRUCTION: {"assembly":["TPARTADD <bundle operands>"],"block":["BSTART.TEPL TPARTADD, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[83],"catalog_records":[{"arguments":[{"constant":"TilePartial_ADD"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTilePartial","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":17,"legality_handler":"TileOperandsLegal_ExecuteTilePartial","mode":3,"name":"TPARTADD","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x071","semantic_handler":"ExecuteTilePartial","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["complex-layout","union"],"mnemonic":"TPARTADD","summary":"Execute the TPARTADD Tile operation contract.","surface":"tile","id":"PTO-TILE-TPARTADD","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPARTADD() => TileOperation
begin
    return TileOperation_TPARTADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TPARTADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;
// DOC-END: operation
