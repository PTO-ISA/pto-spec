// PTO-INSTRUCTION: {"assembly":["TGEMV <bundle operands>"],"block":["BSTART.TGEMV AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)","B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"catalog_indices":[103],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TGEMV","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["DataType","RMode","Sat"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGEMV","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":16,"legality_handler":"TileOperandsLegal_TGEMV","name":"TGEMV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left-vector"},{"field":"source1","role":"right-matrix"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TGEMV","state_effects":["operand:destination0:destination","operand:source0:left-vector","operand:source1:right-matrix"]}],"classification":["matrix-and-matrix-vector","matrix-vector"],"contract":{"block_composition":["BSTART.TGEMV AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)","B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["TGEMV <bundle operands>"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TGEMV AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["The carrier selects exactly CUBE Function 16 and TileOperation_TGEMV.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize.","AType and BType must be supported ordinary Matrix types from one numeric class. M is fixed to one and every Shared binding is illegal.","Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left-vector"},{"field":"source1","role":"right-matrix"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist."],"standalone_opcode":false,"state_effects":["Multiply the matrix by the vector into the destination.","After complete preflight, execute TGEMV with the operand bindings listed above; destination definedness changes only as specified by that handler.","For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TGEMV","mnemonic":"TGEMV","summary":"Multiply the matrix by the vector into the destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TGEMV-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TGEMV MUST select CUBE Function 16 and TileOperation_TGEMV.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// Local N and K MUST be positive and independent of per-PE TSize; M
// MUST equal one.
// AType and BType must be supported ordinary Matrix types from one numeric
// class. M is fixed to one and every Shared binding is illegal.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// NDF-END: PTO-TGEMV-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGEMV()
    => TileOperation
begin
    return TileOperation_TGEMV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractCubeFunction_TGEMV()
    => integer {0..31}
begin
    return 16;
end;

readonly func InstructionContractSharedOperandsAllowed_TGEMV()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TGEMV(
    destination: TileIndex,
    left_vector: TileIndex,
    right_matrix: TileIndex) => boolean
begin
    return TileOperandsLegal_TGEMV(
        destination,
        left_vector,
        right_matrix);
end;

readonly func InstructionContractHandler_TGEMV()
    => TileSemanticHandler
begin
    return TileHandler_TGEMV;
end;
// DOC-END: operation
