// PTO-INSTRUCTION: {"assembly":["TMATMUL_MX <bundle operands>"],"block":["BSTART.TMATMULMX AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB (exactly one)","B.DIM LB0 M or cooperative group_M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)","B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"catalog_indices":[100],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"}],"command_mnemonic":"BSTART.TMATMULMX","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["DataType","RMode","Sat"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMATMUL_MX","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":4,"legality_handler":"TileOperandsLegal_TMATMUL_MX","name":"TMATMUL_MX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"right"},{"field":"source3","role":"column-scale"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMATMUL_MX","state_effects":["operand:destination0:destination","operand:source0:left","operand:source1:row-scale","operand:source2:right","operand:source3:column-scale"]}],"classification":["matrix-and-matrix-vector","matrix-matrix"],"contract":{"block_composition":["BSTART.TMATMULMX AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB (exactly one)","B.DIM LB0 M or cooperative group_M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)","B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["TMATMUL_MX <bundle operands>"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0 defaults Local M or cooperative group_M to one; omitted LB1 and LB2 default N and K to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.","TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TMATMULMX AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["The carrier selects exactly CUBE Function 4 and TileOperation_TMATMUL_MX.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.","A Shared primary must be fully published with all four fixed quarters ready. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has shape group_MxK, Shared B has shape KxN, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 or 32. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.","Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.","Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"right"},{"field":"source3","role":"column-scale"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist."],"standalone_opcode":false,"state_effects":["Multiply matrices using row and column scale Tiles.","After complete preflight, execute TMATMUL_MX with the operand bindings listed above; destination definedness changes only as specified by that handler.","For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.","Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TMATMUL-MX","mnemonic":"TMATMUL_MX","summary":"Multiply matrices using row and column scale Tiles.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMATMUL-MX-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TMATMUL_MX MUST select CUBE Function 4 and TileOperation_TMATMUL_MX.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// Local M, N, and K MUST be positive per-PE dimensions independent of TSize;
// cooperative LB0 MUST be Core-total group_M.
// For every cooperative Shared-input TMATMUL, LB0 MUST be Core-total group_M;
// Shared A MUST have shape group_MxK and Shared B MUST have shape KxN.
// Each matrix side independently requires an E8M0 scale exactly when its MX
// input type is not FP16 or BF16. Published Shared operands may replace the
// right group or both matrix groups; supplementary operands and destinations
// remain Local.
// Shared primaries MUST be fully published and ready in all four fixed quarters.
// TransA/TransB MUST apply only to the corresponding Shared primary. Every
// cooperative nonzero PE mask MUST be 1111; zero-row PEs MUST have no Local effect.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// NDF-END: PTO-TMATMUL-MX-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_MX()
    => TileOperation
begin
    return TileOperation_TMATMUL_MX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractCubeFunction_TMATMUL_MX()
    => integer {0..31}
begin
    return 4;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL_MX()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL_MX(
    destination: TileIndex,
    left: TileIndex,
    row_scale: TileIndex,
    right: TileIndex,
    column_scale: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX(
        destination,
        left,
        row_scale,
        right,
        column_scale);
end;

readonly func InstructionContractHandler_TMATMUL_MX()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX;
end;
// DOC-END: operation
