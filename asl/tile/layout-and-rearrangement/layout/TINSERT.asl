// PTO-INSTRUCTION: {"assembly":["TINSERT <bundle operands>"],"block":["BSTART.SFU TINSERT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[70],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"natural0"},{"operand":"natural1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TINSERT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":3,"legality_handler":"TileOperandsLegal_TINSERT","mode":3,"name":"TINSERT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"natural0","role":"row-offset"},{"field":"natural1","role":"column-offset"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x063","semantic_handler":"TINSERT","state_effects":["operand:destination0:destination","operand:source0:source","operand:natural0:row-offset","operand:natural1:column-offset"]}],"classification":["layout-and-rearrangement","layout"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TINSERT","mnemonic":"TINSERT","summary":"Insert the source Tile into the destination region at the encoded row and column offsets.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TINSERT() => TileOperation
begin
    return TileOperation_TINSERT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TINSERT() => TileSemanticHandler
begin
    return TileHandler_TINSERT;
end;
// DOC-END: operation
