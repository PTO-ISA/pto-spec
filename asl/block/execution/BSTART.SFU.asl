// PTO-INSTRUCTION: {"alias_engine":"SFU","alias_of":"BSTART.TEPL","assembly":["BSTART.SFU Mode, Function, DataType"],"block":[],"catalog_indices":[],"catalog_records":[],"classification":["execution"],"depends_on":["PTO-BLOCK-BSTART-TEPL"],"id":"PTO-BLOCK-BSTART-SFU","mnemonic":"BSTART.SFU","summary":"Canonical Block-start spelling for an operation assigned to the SFU execution engine.","surface":"block"}
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_SFU(
    operation: CommandOperation) => boolean
begin
    return InstructionContractMatches_BSTART_TEPL(operation);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_SFU() => CommandSemanticHandler
begin
    return InstructionContractHandler_BSTART_TEPL();
end;

pure func InstructionContractAliasEngine_BSTART_SFU() => TileExecutionEngine
begin
    return TileEngine_SFU;
end;

pure func InstructionContractAcceptsTileOperation_BSTART_SFU(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_SFU, operation);
end;
// DOC-END: operation
