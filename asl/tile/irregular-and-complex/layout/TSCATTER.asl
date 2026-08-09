// PTO-INSTRUCTION: {"assembly":["TSCATTER <bundle operands>"],"block":["BSTART.SFU TSCATTER, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[82],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TSCATTER","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":16,"legality_handler":"TileOperandsLegal_TSCATTER","mode":3,"name":"TSCATTER","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x070","semantic_handler":"TSCATTER","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:indices"]}],"classification":["irregular-and-complex","layout"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TSCATTER","mnemonic":"TSCATTER","summary":"Scatter source elements by Tile indices into the destination.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSCATTER() => TileOperation
begin
    return TileOperation_TSCATTER;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSCATTER() => TileSemanticHandler
begin
    return TileHandler_TSCATTER;
end;
// DOC-END: operation
