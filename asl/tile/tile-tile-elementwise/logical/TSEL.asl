// PTO-INSTRUCTION: {"assembly":["TSEL <bundle operands>"],"block":["BSTART.TEPL TSEL, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOT","BSTOP"],"catalog_indices":[22],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileSelect","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":26,"legality_handler":"TileOperandsLegal_ExecuteTileSelect","mode":0,"name":"TSEL","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"mask"},{"field":"source1","role":"source-true"},{"field":"source2","role":"source-false"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01A","semantic_handler":"ExecuteTileSelect","state_effects":["operand:destination0:destination","operand:source0:mask","operand:source1:source-true","operand:source2:source-false"]}],"classification":["tile-tile-elementwise","logical"],"mnemonic":"TSEL","summary":"Execute the TSEL Tile operation contract.","surface":"tile"}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSEL() => TileOperation
begin
    return TileOperation_TSEL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSEL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelect;
end;
// DOC-END: operation
