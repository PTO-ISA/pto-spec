// PTO-INSTRUCTION: {"assembly":["TFMA <bundle operands>"],"block":["BSTART.TEPL TFMA, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOT","BSTOP"],"catalog_indices":[24],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TFMA","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":28,"legality_handler":"TileOperandsLegal_TFMA","mode":0,"name":"TFMA","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"multiplicand-left"},{"field":"source1","role":"multiplicand-right"},{"field":"source2","role":"addend"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01C","semantic_handler":"TFMA","state_effects":["operand:destination0:destination","operand:source0:multiplicand-left","operand:source1:multiplicand-right","operand:source2:addend"]}],"classification":["tile-tile-elementwise","arithmetic"],"mnemonic":"TFMA","summary":"Execute the TFMA Tile operation contract.","surface":"tile","id":"PTO-TILE-TFMA","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TFMA() => TileOperation
begin
    return TileOperation_TFMA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TFMA() => TileSemanticHandler
begin
    return TileHandler_TFMA;
end;
// DOC-END: operation
