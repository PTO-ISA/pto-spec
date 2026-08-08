// PTO-INSTRUCTION: {"assembly":["TQUANT <bundle operands>"],"block":["BSTART.TEPL TQUANT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[76],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TQUANT","selector":"0x06A","semantic_handler":"TQUANT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scale"},{"field":"scalar1","role":"zero-point"},{"field":"numeric_control","role":"rounding-and-saturation"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"scalar1"},{"operand":"numeric_control"}],"mode":3,"function":10,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TQUANT","effect_contract":"TQUANT","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scale","operand:scalar1:zero-point","operand:numeric_control:rounding-and-saturation"],"datr_contract":{"allowed_nonzero_fields":["Sat","Canonicalize","DataType","RMode","Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","format-conversion"],"mnemonic":"TQUANT","summary":"Quantize source elements using scale, zero point, rounding, and saturation controls.","surface":"tile","id":"PTO-TILE-TQUANT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TQUANT() => TileOperation
begin
    return TileOperation_TQUANT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TQUANT() => TileSemanticHandler
begin
    return TileHandler_TQUANT;
end;
// DOC-END: operation
