// PTO-INSTRUCTION: {"assembly":["TDEQUANT <bundle operands>"],"block":["BSTART.TEPL TDEQUANT, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[77],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TDEQUANT","selector":"0x06B","semantic_handler":"TDEQUANT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scale"},{"field":"scalar1","role":"zero-point"},{"field":"numeric_control","role":"rounding-and-saturation"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"scalar1"},{"operand":"numeric_control"}],"mode":3,"function":11,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TDEQUANT","effect_contract":"TDEQUANT","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scale","operand:scalar1:zero-point","operand:numeric_control:rounding-and-saturation"],"datr_contract":{"allowed_nonzero_fields":["Sat","Canonicalize","DataType","RMode","Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","format-conversion"],"mnemonic":"TDEQUANT","summary":"Execute the TDEQUANT Tile operation contract.","surface":"tile","id":"PTO-TILE-TDEQUANT","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
