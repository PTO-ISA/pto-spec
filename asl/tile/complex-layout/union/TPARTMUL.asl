// PTO-INSTRUCTION: {"assembly":["TPARTMUL <bundle operands>"],"block":["BSTART.TEPL TPARTMUL, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","BSTOP"],"catalog_indices":[84],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TPARTMUL","selector":"0x072","semantic_handler":"ExecuteTilePartial","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"arguments":[{"constant":"TilePartial_MUL"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"mode":3,"function":18,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTilePartial","effect_contract":"ExecuteTilePartial","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["complex-layout","union"],"mnemonic":"TPARTMUL","summary":"Combine corresponding source partitions by multiplication.","surface":"tile","id":"PTO-TILE-TPARTMUL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPARTMUL() => TileOperation
begin
    return TileOperation_TPARTMUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TPARTMUL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;
// DOC-END: operation
