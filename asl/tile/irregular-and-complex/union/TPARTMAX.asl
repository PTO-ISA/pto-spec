// PTO-INSTRUCTION: {"assembly":["TPARTMAX <bundle operands>"],"block":["BSTART.SFU TPARTMAX, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[85],"catalog_records":[{"arguments":[{"constant":"TilePartial_MAX"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTilePartial","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":19,"legality_handler":"TileOperandsLegal_ExecuteTilePartial","mode":3,"name":"TPARTMAX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x073","semantic_handler":"ExecuteTilePartial","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["irregular-and-complex","union"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TPARTMAX","mnemonic":"TPARTMAX","summary":"Combine corresponding source partitions by maximum selection.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPARTMAX() => TileOperation
begin
    return TileOperation_TPARTMAX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TPARTMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;
// DOC-END: operation
