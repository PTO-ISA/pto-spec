// PTO-INSTRUCTION: {"assembly":["TSELS <bundle operands>"],"block":["BSTART.TEPL TSELS, DataType","B.DATR (optional)","B.DIM LB0","B.DIM (LB1/LB2 for 2D)","B.IOT","B.IOR","BSTOP"],"catalog_indices":[38],"catalog_records":[{"disposition":"accepted-direct-operation","family":"TEPL","command_mnemonic":"BSTART.TEPL","name":"TSELS","selector":"0x03A","semantic_handler":"ExecuteTileSelectScalar","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"mask"},{"field":"source1","role":"source-true"},{"field":"scalar0","role":"scalar-false"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"scalar0"}],"mode":1,"function":26,"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_ExecuteTileSelectScalar","effect_contract":"ExecuteTileSelectScalar","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:mask","operand:source1:source-true","operand:scalar0:scalar-false"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["tile-scalar-elementwise","logical"],"mnemonic":"TSELS","summary":"Execute the TSELS Tile operation contract.","surface":"tile","id":"PTO-TILE-TSELS","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSELS() => TileOperation
begin
    return TileOperation_TSELS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TSELS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelectScalar;
end;
// DOC-END: operation
