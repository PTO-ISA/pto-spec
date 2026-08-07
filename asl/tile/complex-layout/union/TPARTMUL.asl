// PTO-INSTRUCTION: {"assembly":["TPARTMUL <bundle operands>"],"block":["BSTART.TEPL TPARTMUL, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[84],"catalog_records":[{"arguments":[{"constant":"TilePartial_MUL"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTilePartial","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":18,"legality_handler":"TileOperandsLegal_ExecuteTilePartial","mode":3,"name":"TPARTMUL","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x072","semantic_handler":"ExecuteTilePartial","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["complex-layout","union"],"mnemonic":"TPARTMUL","summary":"Execute the TPARTMUL Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPARTMUL() => TileOperation
begin
    return TileOperation_TPARTMUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TPARTMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;
// DOC-END: operation
