// PTO-INSTRUCTION: {"assembly":["TCOLEXPANDMIN <bundle operands>"],"block":["BSTART.TEPL TCOLEXPANDMIN, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[64],"catalog_records":[{"arguments":[{"constant":"TileExpand_MIN"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":26,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TCOLEXPANDMIN","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"broadcast-source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x05A","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:broadcast-source"]}],"classification":["vector-tile-expansion","column-expansion"],"mnemonic":"TCOLEXPANDMIN","summary":"Execute the TCOLEXPANDMIN Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLEXPANDMIN() => TileOperation
begin
    return TileOperation_TCOLEXPANDMIN;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TCOLEXPANDMIN() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
// DOC-END: operation
