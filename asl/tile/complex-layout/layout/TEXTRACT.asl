// PTO-INSTRUCTION: {"assembly":["TEXTRACT <bundle operands>"],"block":["BSTART.TEPL TEXTRACT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[69],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"natural0"},{"operand":"natural1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TEXTRACT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":2,"legality_handler":"TileOperandsLegal_TEXTRACT","mode":3,"name":"TEXTRACT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"natural0","role":"row-offset"},{"field":"natural1","role":"column-offset"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x062","semantic_handler":"TEXTRACT","state_effects":["operand:destination0:destination","operand:source0:source","operand:natural0:row-offset","operand:natural1:column-offset"]}],"classification":["complex-layout","layout"],"mnemonic":"TEXTRACT","summary":"Execute the TEXTRACT Tile operation contract.","surface":"tile","id":"PTO-TILE-TEXTRACT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TEXTRACT() => TileOperation
begin
    return TileOperation_TEXTRACT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TEXTRACT() => TileSemanticHandler
begin
    return TileHandler_TEXTRACT;
end;
// DOC-END: operation
