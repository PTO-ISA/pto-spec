// PTO-INSTRUCTION: {"assembly":["TGEMV <bundle operands>"],"block":["BSTART.CUBE TGEMV AType","B.DATR BType RMode Sat","B.FPATR","B.DIM LB0 N","B.DIM LB1 M","B.DIM LB2 Col","B.IOT Local sources and Local outputs","B.IOR scalar PostProcess parameter (optional)","BSTOP"],"catalog_indices":[103],"catalog_records":[{"disposition":"accepted-direct-operation","family":"CUBE","command_mnemonic":"BSTART.TGEMV","function":16,"name":"TGEMV","semantic_handler":"TGEMV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"matrix"},{"field":"source1","role":"vector"}],"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"contract_status":"reviewed-complete","legality_handler":"TileOperandsLegal_TGEMV","effect_contract":"TGEMV","fault_contract":"ExecuteTileInstruction","restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","state_effects":["operand:destination0:destination","operand:source0:matrix","operand:source1:vector"],"datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"}}],"classification":["matrix","matrix-vector"],"mnemonic":"TGEMV","summary":"Multiply the matrix by the vector into the destination.","surface":"tile","id":"PTO-TILE-TGEMV","depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"]}
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
