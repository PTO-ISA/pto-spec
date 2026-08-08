// PTO-INSTRUCTION: {"assembly":["TRECIP <bundle operands>"],"block":["BSTART.TEPL TRECIP, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[18],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TRECIP","selector":"0x014","semantic_handler":"ExecuteTileUnary","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"arguments":[{"constant":"TileUnary_RECIP"},{"operand":"destination0"},{"operand":"source0"}],"mode":0,"function":20,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileUnary","effect_contract":"ExecuteTileUnary","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["unary-tile-elementwise","transcendental"],"mnemonic":"TRECIP","summary":"Execute the TRECIP Tile operation contract.","surface":"tile","id":"PTO-TILE-TRECIP","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TRECIP() => TileOperation
begin
    return TileOperation_TRECIP;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TRECIP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;
// DOC-END: operation
