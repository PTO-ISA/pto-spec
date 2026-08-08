// PTO-INSTRUCTION: {"assembly":["TQUANT <bundle operands>"],"block":["BSTART.TEPL TQUANT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[76],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"scalar1"},{"operand":"numeric_control"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Sat","Canonicalize","DataType","RMode","Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TQUANT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":10,"legality_handler":"TileOperandsLegal_TQUANT","mode":3,"name":"TQUANT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scale"},{"field":"scalar1","role":"zero-point"},{"field":"numeric_control","role":"rounding-and-saturation"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06A","semantic_handler":"TQUANT","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scale","operand:scalar1:zero-point","operand:numeric_control:rounding-and-saturation"]}],"classification":["complex-layout","format-conversion"],"mnemonic":"TQUANT","summary":"Execute the TQUANT Tile operation contract.","surface":"tile","id":"PTO-TILE-TQUANT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
