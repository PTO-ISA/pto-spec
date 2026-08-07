// PTO-INSTRUCTION: {"assembly":["TROWEXPANDDIV <bundle operands>"],"block":["BSTART.TEPL TROWEXPANDDIV, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[48],"catalog_records":[{"arguments":[{"constant":"TileExpand_DIV"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":8,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TROWEXPANDDIV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"broadcast-source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x048","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:broadcast-source"]}],"classification":["vector-tile-expansion","row-expansion"],"mnemonic":"TROWEXPANDDIV","summary":"Execute the TROWEXPANDDIV Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWEXPANDDIV() => TileOperation
begin
    return TileOperation_TROWEXPANDDIV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TROWEXPANDDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
// DOC-END: operation
