// PTO-INSTRUCTION: {"assembly":["TFILLPAD <bundle operands>"],"block":["BSTART.TEPL TFILLPAD, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[72],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"TFILLPAD","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":5,"legality_handler":"TileOperandsLegal_TFILLPAD","mode":3,"name":"TFILLPAD","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"padding"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x065","semantic_handler":"TFILLPAD","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:padding"]}],"classification":["complex-layout","initialization"],"mnemonic":"TFILLPAD","summary":"Execute the TFILLPAD Tile operation contract.","surface":"tile","id":"PTO-TILE-TFILLPAD","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TFILLPAD() => TileOperation
begin
    return TileOperation_TFILLPAD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TFILLPAD() => TileSemanticHandler
begin
    return TileHandler_TFILLPAD;
end;
// DOC-END: operation
