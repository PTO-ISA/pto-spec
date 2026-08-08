// PTO-INSTRUCTION: {"assembly":["TCI <bundle operands>"],"block":["BSTART.TEPL TCI, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[73],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TCI","selector":"0x066","semantic_handler":"TCI","operands":[{"field":"destination0","role":"destination"},{"field":"scalar0","role":"start"},{"field":"flag0","role":"descending"}],"arguments":[{"operand":"destination0"},{"operand":"scalar0"},{"operand":"flag0"}],"mode":3,"function":6,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TCI","effect_contract":"TCI","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:scalar0:start","operand:flag0:descending"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["complex-layout","initialization"],"mnemonic":"TCI","summary":"Initialize destination elements as an ascending or descending counter sequence.","surface":"tile","id":"PTO-TILE-TCI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCI() => TileOperation
begin
    return TileOperation_TCI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCI() => TileSemanticHandler
begin
    return TileHandler_TCI;
end;
// DOC-END: operation
