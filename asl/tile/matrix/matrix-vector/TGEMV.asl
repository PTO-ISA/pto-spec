// PTO-INSTRUCTION: {"assembly":["TGEMV <bundle operands>"],"block":["BSTART.CUBE TGEMV AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[103],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TGEMV","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGEMV","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":16,"legality_handler":"TileOperandsLegal_TGEMV","name":"TGEMV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"matrix"},{"field":"source1","role":"vector"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TGEMV","state_effects":["operand:destination0:destination","operand:source0:matrix","operand:source1:vector"]}],"classification":["matrix","matrix-vector"],"mnemonic":"TGEMV","summary":"Execute the TGEMV Tile operation contract.","surface":"tile","id":"PTO-TILE-TGEMV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV() => TileOperation
begin
    return TileOperation_TGEMV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractMatrixShapeLegal_TGEMV_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV() => TileSemanticHandler
begin
    return TileHandler_TGEMV;
end;
// DOC-END: operation
