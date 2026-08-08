// PTO-INSTRUCTION: {"assembly":["TADDS <bundle operands>"],"block":["BSTART.TEPL TADDS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[25],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TADDS","selector":"0x020","semantic_handler":"ExecuteTileScalar","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"}],"arguments":[{"constant":"TileBinary_ADD"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"mode":1,"function":0,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileScalar","effect_contract":"ExecuteTileScalar","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["tile-scalar-elementwise","arithmetic"],"mnemonic":"TADDS","summary":"Execute the TADDS Tile operation contract.","surface":"tile","id":"PTO-TILE-TADDS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TADDS() => TileOperation
begin
    return TileOperation_TADDS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TADDS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
// DOC-END: operation
