// PTO-INSTRUCTION: {"assembly":["TCOLPROD <bundle operands>"],"block":["BSTART.SFU TCOLPROD, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[57],"catalog_records":[{"arguments":[{"constant":"TileReduction_PRODUCT"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileReduction","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":19,"legality_handler":"TileOperandsLegal_ExecuteTileReduction","mode":2,"name":"TCOLPROD","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x053","semantic_handler":"ExecuteTileReduction","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["reduce-and-expand","column-reduction"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TCOLPROD","mnemonic":"TCOLPROD","summary":"Reduce each source col to its product.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLPROD() => TileOperation
begin
    return TileOperation_TCOLPROD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCOLPROD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileReduction;
end;
// DOC-END: operation
