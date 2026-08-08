// PTO-INSTRUCTION: {"assembly":["TGATHER <bundle operands>"],"block":["BSTART.TEPL TGATHER, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[81],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGATHER","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":15,"legality_handler":"TileOperandsLegal_TGATHER","mode":3,"name":"TGATHER","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06F","semantic_handler":"TGATHER","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:indices"]}],"classification":["complex-layout","layout"],"mnemonic":"TGATHER","summary":"Execute the TGATHER Tile operation contract.","surface":"tile","id":"PTO-TILE-TGATHER","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
