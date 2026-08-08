// PTO-INSTRUCTION: {"assembly":["TSORT <bundle operands>"],"block":["BSTART.TEPL TSORT, DataType","B.DIM sort_width -> LB0","B.IOT","BSTOP"],"catalog_indices":[78],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TSORT","selector":"0x06C","semantic_handler":"TSORT","operands":[{"field":"destination0","role":"destination"},{"field":"destination1","role":"original-indices-u32"},{"field":"source0","role":"source"},{"field":"sort_width","role":"sort-width"},{"field":"flag0","role":"descending"}],"arguments":[{"operand":"destination0"},{"operand":"destination1"},{"operand":"source0"},{"operand":"sort_width"},{"operand":"flag0"}],"mode":3,"function":12,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TSORT","effect_contract":"TSORT","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:destination1:original-indices-u32","operand:source0:source","operand:sort_width:sort-width","operand:flag0:descending"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["complex-layout","sorting"],"mnemonic":"TSORT","summary":"Sort source groups, returning ordered values and original U32 indices.","surface":"tile","id":"PTO-TILE-TSORT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSORT() => TileOperation
begin
    return TileOperation_TSORT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSORT() => TileSemanticHandler
begin
    return TileHandler_TSORT;
end;
// DOC-END: operation
