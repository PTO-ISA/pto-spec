// PTO-INSTRUCTION: {"assembly":["TCI <bundle operands>"],"block":["BSTART.TEPL TCI, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[73],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"scalar0"},{"operand":"flag0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TCI","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_TCI","mode":3,"name":"TCI","operands":[{"field":"destination0","role":"destination"},{"field":"scalar0","role":"start"},{"field":"flag0","role":"descending"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x066","semantic_handler":"TCI","state_effects":["operand:destination0:destination","operand:scalar0:start","operand:flag0:descending"]}],"classification":["complex-layout","initialization"],"mnemonic":"TCI","summary":"Execute the TCI Tile operation contract.","surface":"tile","id":"PTO-TILE-TCI","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
