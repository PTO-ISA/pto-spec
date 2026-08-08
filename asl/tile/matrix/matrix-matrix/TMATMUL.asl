// PTO-INSTRUCTION: {"assembly":["TMATMUL <bundle operands>"],"block":["BSTART.CUBE TMATMUL AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOS Shared operand binder (optional)","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[97],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TMATMUL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMATMUL","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":0,"legality_handler":"TileOperandsLegal_TMATMUL","name":"TMATMUL","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMATMUL","state_effects":["operand:destination0:destination","operand:source0:left","operand:source1:right"]}],"classification":["matrix","matrix-matrix"],"mnemonic":"TMATMUL","summary":"Execute the TMATMUL Tile operation contract.","surface":"tile","id":"PTO-TILE-TMATMUL","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL() => TileOperation
begin
    return TileOperation_TMATMUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TMATMUL_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL() => TileSemanticHandler
begin
    return TileHandler_TMATMUL;
end;
// DOC-END: operation
