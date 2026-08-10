// PTO-INSTRUCTION: {"assembly":["TSORT <bundle operands>"],"block":["BSTART.SFU TSORT, DataType","B.DIM sort_width -> LB0","B.IOT","B.IOR","BSTOP"],"catalog_indices":[78],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"destination1"},{"operand":"source0"},{"operand":"sort_width"},{"operand":"flag0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TSORT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":12,"legality_handler":"TileOperandsLegal_TSORT","mode":3,"name":"TSORT","operands":[{"field":"destination0","role":"destination"},{"field":"destination1","role":"original-indices-u32"},{"field":"source0","role":"source"},{"field":"sort_width","role":"sort-width"},{"field":"flag0","role":"descending"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06C","semantic_handler":"TSORT","state_effects":["operand:destination0:destination","operand:destination1:original-indices-u32","operand:source0:source","operand:sort_width:sort-width","operand:flag0:descending"]}],"classification":["irregular-and-complex","sorting"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TSORT","mnemonic":"TSORT","summary":"Sort source groups, returning ordered values and original U32 indices.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSORT() => TileOperation
begin
    return TileOperation_TSORT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
// Complete-bundle B.IOR consumes only descending in RegSrc0.  The encoded
// zero selector is distinct from omission; raw values are validated before
// BSTOP resolves destinations.  Equal keys retain source/index order.
readonly func InstructionContractHandler_TSORT() => TileSemanticHandler
begin
    return TileHandler_TSORT;
end;
// DOC-END: operation
