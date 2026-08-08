// PTO-INSTRUCTION: {"assembly":["TCONCAT <bundle operands>"],"block":["BSTART.TEPL TCONCAT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[68],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"axis"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TCONCAT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":0,"legality_handler":"TileOperandsLegal_TCONCAT","mode":3,"name":"TCONCAT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"},{"field":"axis","role":"axis"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x060","semantic_handler":"TCONCAT","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right","operand:axis:axis"]}],"classification":["complex-layout","layout"],"mnemonic":"TCONCAT","summary":"Execute the TCONCAT Tile operation contract.","surface":"tile","id":"PTO-TILE-TCONCAT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCONCAT() => TileOperation
begin
    return TileOperation_TCONCAT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCONCAT() => TileSemanticHandler
begin
    return TileHandler_TCONCAT;
end;
// DOC-END: operation
