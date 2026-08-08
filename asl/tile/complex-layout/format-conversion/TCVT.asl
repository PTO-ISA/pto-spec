// PTO-INSTRUCTION: {"assembly":["TCVT <bundle operands>"],"block":["BSTART.TEPL TCVT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[23],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TCVT","selector":"0x01B","semantic_handler":"TCVT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"numeric_control","role":"rounding-and-saturation"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"numeric_control"}],"mode":0,"function":27,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TCVT","effect_contract":"TCVT","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:numeric_control:rounding-and-saturation"],"datr_contract":{"allowed_nonzero_fields":["Sat","Canonicalize","DataType","RMode","Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","format-conversion"],"mnemonic":"TCVT","summary":"Execute the TCVT Tile operation contract.","surface":"tile","id":"PTO-TILE-TCVT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCVT() => TileOperation
begin
    return TileOperation_TCVT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCVT() => TileSemanticHandler
begin
    return TileHandler_TCVT;
end;
// DOC-END: operation
