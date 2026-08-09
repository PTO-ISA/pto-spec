// PTO-INSTRUCTION: {"assembly":["TNEG <bundle operands>"],"block":["BSTART.VEC TNEG, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[15],"catalog_records":[{"arguments":[{"constant":"TileUnary_NEG"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileUnary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":17,"legality_handler":"TileOperandsLegal_ExecuteTileUnary","mode":0,"name":"TNEG","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x011","semantic_handler":"ExecuteTileUnary","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["elementwise-tile-tile","logical"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TNEG","mnemonic":"TNEG","summary":"Apply elementwise arithmetic negation to the source Tile.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TNEG() => TileOperation
begin
    return TileOperation_TNEG;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TNEG() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;
// DOC-END: operation
