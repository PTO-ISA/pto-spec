// PTO-INSTRUCTION: {"assembly":["TFILLPAD <bundle operands>"],"block":["BSTART.TEPL TFILLPAD, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[72],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TFILLPAD","selector":"0x065","semantic_handler":"TFILLPAD","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"scalar0","role":"padding"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"mode":3,"function":5,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TFILLPAD","effect_contract":"TFILLPAD","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source","operand:scalar0:padding"],"datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"}}],"classification":["complex-layout","initialization"],"mnemonic":"TFILLPAD","summary":"Execute the TFILLPAD Tile operation contract.","surface":"tile","id":"PTO-TILE-TFILLPAD","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
