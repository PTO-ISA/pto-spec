// PTO-INSTRUCTION: {"assembly":["TMATMUL_MX_ACC <bundle operands>"],"block":["BSTART.TMATMULMX.ACC AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)","B.DIM LB0 M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; executing mask 1111)","B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"catalog_indices":[102],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"},{"operand":"source4"}],"command_mnemonic":"BSTART.TMATMULMX.ACC","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["DataType","RMode","Sat"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMATMUL_MX_ACC","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_TMATMUL_MX_ACC","name":"TMATMUL_MX_ACC","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"accumulator"},{"field":"source1","role":"left"},{"field":"source2","role":"row-scale"},{"field":"source3","role":"right"},{"field":"source4","role":"column-scale"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMATMUL_MX_ACC","state_effects":["operand:destination0:destination","operand:source0:accumulator","operand:source1:left","operand:source2:row-scale","operand:source3:right","operand:source4:column-scale"]}],"classification":["matrix-and-matrix-vector","matrix-matrix"],"contract":{"block_composition":["BSTART.TMATMULMX.ACC AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)","B.DIM LB0 M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; executing mask 1111)","B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["TMATMUL_MX_ACC <bundle operands>"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0, LB1, and LB2 default M, N, and K independently to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TMATMULMX.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; executing mask 1111); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A, A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["The carrier selects exactly CUBE Function 6 and TileOperation_TMATMUL_MX_ACC.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.","Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. C is one explicit Local MxN accumulator source and D is a newly published destination; C and D may use one architectural Tile name. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.","Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"accumulator"},{"field":"source1","role":"left"},{"field":"source2","role":"row-scale"},{"field":"source3","role":"right"},{"field":"source4","role":"column-scale"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist."],"standalone_opcode":false,"state_effects":["Multiply scaled matrices and accumulate into the supplied accumulator Tile.","After complete preflight, execute TMATMUL_MX_ACC with the operand bindings listed above; destination definedness changes only as specified by that handler.","For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TMATMUL-MX-ACC","mnemonic":"TMATMUL_MX_ACC","summary":"Multiply scaled matrices and accumulate into the supplied accumulator Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMATMUL-MX-ACC-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TMATMUL_MX_ACC MUST select CUBE Function 6 and TileOperation_TMATMUL_MX_ACC.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// and every Local M/N/K MUST be positive and independent of per-PE
// TSize. The current Shared path retains its existing dimension rule.
// Each matrix side independently requires an E8M0 scale exactly when its MX
// input type is not FP16 or BF16. C is one explicit Local MxN accumulator
// source and D is a newly published destination; C and D may use one
// architectural Tile name. Published Shared operands may replace the right
// group or both matrix groups; supplementary operands and destinations remain
// Local.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// NDF-END: PTO-TMATMUL-MX-ACC-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_MX_ACC()
    => TileOperation
begin
    return TileOperation_TMATMUL_MX_ACC;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractCubeFunction_TMATMUL_MX_ACC()
    => integer {0..31}
begin
    return 6;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL_MX_ACC()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL_MX_ACC(
    destination: TileIndex,
    accumulator: TileIndex,
    left: TileIndex,
    row_scale: TileIndex,
    right: TileIndex,
    column_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX_ACC(
        destination,
        accumulator,
        left,
        row_scale,
        right,
        column_scale);
end;

readonly func InstructionContractHandler_TMATMUL_MX_ACC()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_ACC;
end;
// DOC-END: operation
