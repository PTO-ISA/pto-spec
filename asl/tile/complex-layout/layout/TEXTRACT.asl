// PTO-INSTRUCTION: {"assembly":["TEXTRACT <bundle operands>"],"block":["BSTART.TEPL TEXTRACT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[69],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TEXTRACT","selector":"0x062","semantic_handler":"TEXTRACT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"natural0","role":"row-offset"},{"field":"natural1","role":"column-offset"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"natural0"},{"operand":"natural1"}],"mode":3,"function":2,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TEXTRACT","effect_contract":"TEXTRACT","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:natural0:row-offset","operand:natural1:column-offset"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","layout"],"mnemonic":"TEXTRACT","summary":"Extract a rectangular source region at the encoded row and column offsets.","surface":"tile","id":"PTO-TILE-TEXTRACT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
