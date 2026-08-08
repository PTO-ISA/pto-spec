// PTO-INSTRUCTION: {"assembly":["TGATHER <bundle operands>"],"block":["BSTART.TEPL TGATHER, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[81],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TGATHER","selector":"0x06F","semantic_handler":"TGATHER","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":3,"function":15,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TGATHER","effect_contract":"TGATHER","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:indices"],"datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"}}],"classification":["complex-layout","layout"],"mnemonic":"TGATHER","summary":"Gather source elements by Tile indices into the destination.","surface":"tile","id":"PTO-TILE-TGATHER","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGATHER() => TileOperation
begin
    return TileOperation_TGATHER;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TGATHER() => TileSemanticHandler
begin
    return TileHandler_TGATHER;
end;
// DOC-END: operation
