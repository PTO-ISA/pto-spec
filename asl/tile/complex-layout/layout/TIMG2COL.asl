// PTO-INSTRUCTION: {"assembly":["TIMG2COL <bundle operands>"],"block":["BSTART.TEPL TIMG2COL, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[71],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TIMG2COL","selector":"0x064","semantic_handler":"TIMG2COL","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"positive0","role":"kernel-rows"},{"field":"positive1","role":"kernel-columns"},{"field":"positive2","role":"stride-rows"},{"field":"positive3","role":"stride-columns"},{"field":"natural0","role":"pad-rows"},{"field":"natural1","role":"pad-columns"},{"field":"scalar0","role":"padding"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"positive0"},{"operand":"positive1"},{"operand":"positive2"},{"operand":"positive3"},{"operand":"natural0"},{"operand":"natural1"},{"operand":"scalar0"}],"mode":3,"function":4,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TIMG2COL","effect_contract":"TIMG2COL","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:positive0:kernel-rows","operand:positive1:kernel-columns","operand:positive2:stride-rows","operand:positive3:stride-columns","operand:natural0:pad-rows","operand:natural1:pad-columns","operand:scalar0:padding"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","layout"],"mnemonic":"TIMG2COL","summary":"Transform an image Tile into kernel-column layout using kernel, stride, padding, and fill operands.","surface":"tile","id":"PTO-TILE-TIMG2COL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TIMG2COL() => TileOperation
begin
    return TileOperation_TIMG2COL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TIMG2COL() => TileSemanticHandler
begin
    return TileHandler_TIMG2COL;
end;
// DOC-END: operation
