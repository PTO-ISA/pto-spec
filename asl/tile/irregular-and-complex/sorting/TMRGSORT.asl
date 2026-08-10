// PTO-INSTRUCTION: {"assembly":["TMRGSORT <bundle operands>"],"block":["BSTART.SFU TMRGSORT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[79],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"flag0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMRGSORT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_TMRGSORT","mode":3,"name":"TMRGSORT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"},{"field":"flag0","role":"descending"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06D","semantic_handler":"TMRGSORT","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right","operand:flag0:descending"]}],"classification":["irregular-and-complex","sorting"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TMRGSORT","mnemonic":"TMRGSORT","summary":"Merge two sorted source Tiles in the selected ascending or descending order.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMRGSORT() => TileOperation
begin
    return TileOperation_TMRGSORT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
// Complete-bundle B.IOR consumes descending in RegSrc0. Omission keeps the
// ascending default; encoded zero is explicit. Equal keys select the left
// source first, and inputs must already be sorted in the selected direction.
readonly func InstructionContractHandler_TMRGSORT() => TileSemanticHandler
begin
    return TileHandler_TMRGSORT;
end;
// DOC-END: operation
