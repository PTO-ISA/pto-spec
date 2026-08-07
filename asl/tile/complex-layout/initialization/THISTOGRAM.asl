// PTO-INSTRUCTION: {"assembly":["THISTOGRAM <bundle operands>"],"block":["BSTART.TEPL THISTOGRAM, DataType","B.DATR selected_byte","B.IOT","BSTOP"],"catalog_indices":[75],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"selected_byte"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","DataType"],"pad_union":"histogram-byte-id"},"disposition":"accepted-direct-operation","effect_contract":"THISTOGRAM","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":8,"legality_handler":"TileOperandsLegal_THISTOGRAM","mode":3,"name":"THISTOGRAM","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"source1","role":"indices"},{"field":"selected_byte","role":"selected-byte"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x068","semantic_handler":"THISTOGRAM","state_effects":["operand:destination0:destination","operand:source0:source","operand:source1:indices","operand:selected_byte:selected-byte"]}],"classification":["complex-layout","initialization"],"mnemonic":"THISTOGRAM","summary":"Execute the THISTOGRAM Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_THISTOGRAM() => TileOperation
begin
    return TileOperation_THISTOGRAM;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_THISTOGRAM() => TileSemanticHandler
begin
    return TileHandler_THISTOGRAM;
end;
// DOC-END: operation
