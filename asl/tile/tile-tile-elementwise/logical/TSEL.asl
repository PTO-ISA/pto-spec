// PTO-INSTRUCTION: {"assembly":["TSEL <bundle operands>"],"block":["BSTART.TEPL TSEL, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOT","BSTOP"],"catalog_indices":[22],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TSEL","selector":"0x01A","semantic_handler":"ExecuteTileSelect","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"mask"},{"field":"source1","role":"source-true"},{"field":"source2","role":"source-false"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"mode":0,"function":26,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileSelect","effect_contract":"ExecuteTileSelect","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:mask","operand:source1:source-true","operand:source2:source-false"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["tile-tile-elementwise","logical"],"mnemonic":"TSEL","summary":"Execute the TSEL Tile operation contract.","surface":"tile","id":"PTO-TILE-TSEL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
