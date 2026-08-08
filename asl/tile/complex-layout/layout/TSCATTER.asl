// PTO-INSTRUCTION: {"assembly":["TSCATTER <bundle operands>"],"block":["BSTART.TEPL TSCATTER, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[82],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TSCATTER","selector":"0x070","semantic_handler":"TSCATTER","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":3,"function":16,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TSCATTER","effect_contract":"TSCATTER","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:indices"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","layout"],"mnemonic":"TSCATTER","summary":"Execute the TSCATTER Tile operation contract.","surface":"tile","id":"PTO-TILE-TSCATTER","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
