// PTO-INSTRUCTION: {"assembly":["TMRGSORT <bundle operands>"],"block":["BSTART.TEPL TMRGSORT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[79],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"flag0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMRGSORT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_TMRGSORT","mode":3,"name":"TMRGSORT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"},{"field":"flag0","role":"descending"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06D","semantic_handler":"TMRGSORT","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right","operand:flag0:descending"]}],"classification":["complex-layout","sorting"],"mnemonic":"TMRGSORT","summary":"Execute the TMRGSORT Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMRGSORT() => TileOperation
begin
    return TileOperation_TMRGSORT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TMRGSORT() => TileSemanticHandler
begin
    return TileHandler_TMRGSORT;
end;
// DOC-END: operation
