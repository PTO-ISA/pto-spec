// PTO-INSTRUCTION: {"alias_engine":"VEC","alias_of":"BSTART.TEPL","assembly":["BSTART.VEC Mode, Function, DataType"],"block":[],"catalog_indices":[],"catalog_records":[],"classification":["execution"],"depends_on":["PTO-BLOCK-BSTART-TEPL"],"id":"PTO-BLOCK-BSTART-VEC","mnemonic":"BSTART.VEC","summary":"Canonical Block-start spelling for an operation assigned to the VEC execution engine.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_VEC(
    operation: CommandOperation) => boolean
begin
    return InstructionContractMatches_BSTART_TEPL(operation);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_VEC() => CommandSemanticHandler
begin
    return InstructionContractHandler_BSTART_TEPL();
end;

pure func InstructionContractAliasEngine_BSTART_VEC() => TileExecutionEngine
begin
    return TileEngine_VEC;
end;

pure func InstructionContractAcceptsTileOperation_BSTART_VEC(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_VEC, operation);
end;
// DOC-END: operation
