// PTO-INSTRUCTION: {"assembly":["TINSERT <bundle operands>"],"block":["BSTART.TEPL TINSERT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[70],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TINSERT","selector":"0x063","semantic_handler":"TINSERT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"natural0","role":"row-offset"},{"field":"natural1","role":"column-offset"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"natural0"},{"operand":"natural1"}],"mode":3,"function":3,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TINSERT","effect_contract":"TINSERT","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:natural0:row-offset","operand:natural1:column-offset"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","layout"],"mnemonic":"TINSERT","summary":"Insert the source Tile into the destination region at the encoded row and column offsets.","surface":"tile","id":"PTO-TILE-TINSERT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
