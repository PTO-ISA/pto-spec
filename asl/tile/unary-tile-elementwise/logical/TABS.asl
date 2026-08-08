// PTO-INSTRUCTION: {"assembly":["TABS <bundle operands>"],"block":["BSTART.TEPL TABS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[13],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TABS","selector":"0x00F","semantic_handler":"ExecuteTileUnary","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"arguments":[{"constant":"TileUnary_ABS"},{"operand":"destination0"},{"operand":"source0"}],"mode":0,"function":15,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileUnary","effect_contract":"ExecuteTileUnary","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["unary-tile-elementwise","logical"],"mnemonic":"TABS","summary":"Execute the TABS Tile operation contract.","surface":"tile","id":"PTO-TILE-TABS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TABS() => TileOperation
begin
    return TileOperation_TABS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TABS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;
// DOC-END: operation
