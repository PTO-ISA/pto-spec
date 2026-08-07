// PTO-INSTRUCTION: {"assembly":["TMAXS <bundle operands>"],"block":["BSTART.TEPL TMAXS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[35],"catalog_records":[{"arguments":[{"constant":"TileBinary_MAX"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":11,"legality_handler":"TileOperandsLegal_ExecuteTileScalar","mode":1,"name":"TMAXS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"scalar"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x02B","semantic_handler":"ExecuteTileScalar","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:scalar"]}],"classification":["tile-scalar-elementwise","arithmetic"],"mnemonic":"TMAXS","summary":"Execute the TMAXS Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMAXS() => TileOperation
begin
    return TileOperation_TMAXS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TMAXS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
// DOC-END: operation
