// PTO-INSTRUCTION: {"alias_engine":"SFU","alias_of":"BSTART.TEPL","assembly":["BSTART.SFU TileOp, DataType"],"block":[],"catalog_indices":[],"catalog_records":[],"classification":["execution"],"contract":{"block_composition":["TileOp resolves to one assigned TEPL Mode:Function selector whose execution engine is SFU; the alias adds no encoding bits or ownership.","The resulting block uses the same descriptor, header composition, commit, and rollback rules as BSTART.TEPL."],"canonical_assembly":["BSTART.SFU TileOp, DataType"],"defaults":["BSTART.SFU is a canonical engine alias for BSTART.TEPL; it owns no separate encoding or default."],"encoding_class":"encoding-alias","examples":["BSTART.SFU TEXP, FP32"],"exceptions":["An unknown TileOp, selector hole, VEC/TLSU/CUBE operation, reserved DataType, or invalid descriptor raises before predecessor retirement or new BARG effects."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{},"legality":["TileOp must name an assigned direct operation carried by BSTART.TEPL and assigned to SFU.","The spelling owns no separate encoding; the resolved Mode:Function and DataType bits are exactly the BSTART.TEPL carrier bits.","Canonical assembly and disassembly use BSTART.SFU for every SFU operation."],"memory_effects":["none"],"operands":[{"field":"TileOp","role":"assigned SFU operation mnemonic that resolves the Mode:Function selector"},{"field":"DataType","role":"tile element data type selector"}],"ordering":["Alias resolution, SFU-engine match, carrier fields, and descriptor legality precede predecessor retirement and BARG publication."],"standalone_opcode":false,"state_effects":["Installs exactly the BSTART.TEPL descriptor resolved from TileOp and DataType; this alias has no additional state.","The selected SFU operation executes only when the block commits."]},"depends_on":["PTO-BLOCK-BSTART-TEPL"],"id":"PTO-BLOCK-BSTART-SFU","mnemonic":"BSTART.SFU","summary":"Canonical Block-start spelling for an operation assigned to the SFU execution engine.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-SFU-DECISION-BINDING-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.SFU MUST implement the mnemonic-local canonical assembly, encoded
// legality, defaults, state and memory effects, ordering, and fault boundaries
// declared in this owner. The operation region below is the executable binding
// for every accepted decision that names this mnemonic.
// NDF-END: PTO-BSTART-SFU-DECISION-BINDING-001
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
