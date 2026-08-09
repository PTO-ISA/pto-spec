// PTO-INSTRUCTION: {"assembly":["TDEQUANT <bundle operands>"],"block":["BSTART.SFU TDEQUANT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[77],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"scalar1"},{"operand":"numeric_control"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Sat","Canonicalize","DataType","RMode","Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TDEQUANT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":11,"legality_handler":"TileOperandsLegal_TDEQUANT","mode":3,"name":"TDEQUANT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scale"},{"field":"scalar1","role":"zero-point"},{"field":"numeric_control","role":"rounding-and-saturation"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06B","semantic_handler":"TDEQUANT","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scale","operand:scalar1:zero-point","operand:numeric_control:rounding-and-saturation"]}],"classification":["irregular-and-complex","format-conversion"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"SFU","id":"PTO-TILE-TDEQUANT","mnemonic":"TDEQUANT","summary":"Dequantize source elements using scale, zero point, rounding, and saturation controls.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TDEQUANT() => TileOperation
begin
    return TileOperation_TDEQUANT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TDEQUANT() => TileSemanticHandler
begin
    return TileHandler_TDEQUANT;
end;
// DOC-END: operation
