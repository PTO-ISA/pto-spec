// PTO-INSTRUCTION: {"assembly":["TCVT <bundle operands>"],"block":["BSTART.VEC TCVT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[23],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"numeric_control"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Sat","Canonicalize","DataType","RMode","Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TCVT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":27,"legality_handler":"TileOperandsLegal_TCVT","mode":0,"name":"TCVT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"numeric_control","role":"rounding-and-saturation"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01B","semantic_handler":"TCVT","state_effects":["operand:destination0:destination","operand:source0:source","operand:numeric_control:rounding-and-saturation"]}],"classification":["elementwise-tile-tile","format-conversion"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TCVT","mnemonic":"TCVT","summary":"Convert source elements to the destination data type under rounding and saturation controls.","surface":"tile"}
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
