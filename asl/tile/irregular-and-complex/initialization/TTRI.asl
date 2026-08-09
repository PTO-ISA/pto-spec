// PTO-INSTRUCTION: {"assembly":["TTRI <bundle operands>"],"block":["BSTART.SFU TTRI, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[74],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"flag0"},{"operand":"diagonal"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TTRI","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_TTRI","mode":3,"name":"TTRI","operands":[{"field":"destination0","role":"destination"},{"field":"flag0","role":"upper"},{"field":"diagonal","role":"diagonal"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x067","semantic_handler":"TTRI","state_effects":["operand:destination0:destination","operand:flag0:upper","operand:diagonal:diagonal"]}],"classification":["irregular-and-complex","initialization"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TTRI","mnemonic":"TTRI","summary":"Initialize the selected upper or lower triangular region relative to the diagonal.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TTRI() => TileOperation
begin
    return TileOperation_TTRI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TTRI() => TileSemanticHandler
begin
    return TileHandler_TTRI;
end;
// DOC-END: operation
