// PTO-INSTRUCTION: {"assembly":["TMRGSORT <bundle operands>"],"block":["BSTART.TEPL TMRGSORT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[79],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TMRGSORT","selector":"0x06D","semantic_handler":"TMRGSORT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"},{"field":"flag0","role":"descending"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"flag0"}],"mode":3,"function":13,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TMRGSORT","effect_contract":"TMRGSORT","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right","operand:flag0:descending"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["complex-layout","sorting"],"mnemonic":"TMRGSORT","summary":"Merge two sorted source Tiles in the selected ascending or descending order.","surface":"tile","id":"PTO-TILE-TMRGSORT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
