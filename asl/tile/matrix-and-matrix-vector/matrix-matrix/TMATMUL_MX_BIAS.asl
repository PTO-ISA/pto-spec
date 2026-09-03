// PTO-INSTRUCTION: {"assembly":["TMATMUL_MX_BIAS <bundle operands>"],"block":["BSTART.TMATMULMX.BIAS AType","B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)","B.DIM LB0 M or cooperative group_M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)","B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale, 1xN Bias","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"catalog_indices":[95],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"},{"operand":"source4"}],"command_mnemonic":"BSTART.TMATMULMX.BIAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["DataType","RMode","Sat","PadValueOrByteId"],"pad_union":"matrix-cctrl"},"disposition":"accepted-direct-operation","effect_contract":"TMATMUL_MX_BIAS","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":5,"legality_handler":"TileOperandsLegal_TMATMUL_MX_BIAS","name":"TMATMUL_MX_BIAS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"right"},{"field":"source3","role":"column-scale"},{"field":"source4","role":"bias"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMATMUL_MX_BIAS","state_effects":["operand:destination0:destination","operand:source0:left","operand:source1:row-scale","operand:source2:right","operand:source3:column-scale","operand:source4:bias","runtime:CurrentBundleCCTRL:raw-partial-and-transparent-cache-hints"]}],"classification":["matrix-and-matrix-vector","matrix-matrix"],"contract":{"block_composition":["BSTART.TMATMULMX.BIAS AType","B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)","B.DIM LB0 M or cooperative group_M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)","B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale, 1xN Bias","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["TMATMUL_MX_BIAS <bundle operands>"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0 defaults Local M or cooperative group_M to one; omitted LB1 and LB2 default N and K to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias remains an ordinary row-major 1xN accumulator-type Tile. Each side uses group-32 E8M0 or HiF4X2 group-64 U32 scale; Local scales use CUBE_M32 and Shared scales remain ordinary Tiles.","TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared.","Omitted CCTRL selects 00: final D output and no transparent-cache hint."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TMATMULMX.BIAS AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale, 1xN Bias; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["The carrier selects exactly CUBE Function 5 and TileOperation_TMATMUL_MX_BIAS.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias remains an ordinary row-major 1xN accumulator-type Tile. Each side uses group-32 E8M0 or HiF4X2 group-64 U32 scale; Local scales use CUBE_M32 and Shared scales remain ordinary Tiles.","A Shared primary must satisfy hardware-maintained whole-parent readiness and publication before payload access; fixed-quarter allocation or initialization masks are not a prerequisite. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has shape group_MxK, Shared B has shape KxN, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 for group_M<=64 and 32 for group_M>=65. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.","Each non-FP16/BF16 side requires its assigned scale: group-32 E8M0 for MX FP8/FP4 or group-64 U32 for HiF4X2. Bias is one Local row-major 1xN accumulator-type source. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.","Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.","For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"row-scale"},{"field":"source2","role":"right"},{"field":"source3","role":"column-scale"},{"field":"source4","role":"bias"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.","Transparent-cache hints occur only after complete preflight and cannot alter source snapshots, D allocation or publication, faults, or numeric status."],"standalone_opcode":false,"state_effects":["Multiply scaled matrices and add the bias Tile.","After complete preflight, execute TMATMUL_MX_BIAS with the operand bindings listed above; destination definedness changes only as specified by that handler.","For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.","Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged.","Always publish D; CCTRL[0]=1 publishes raw accumulator-type D and may hint cache replacement, while ACC CCTRL[1]=1 may hint cache use or prefetch of explicit C. Hint handling is not architecturally observable."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TMATMUL-MX-BIAS","mnemonic":"TMATMUL_MX_BIAS","summary":"Multiply scaled matrices and add the bias Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMATMUL-MX-BIAS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TMATMUL_MX_BIAS MUST select CUBE Function 5 and TileOperation_TMATMUL_MX_BIAS.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// Local M, N, and K MUST be positive per-PE dimensions independent of TSize;
// cooperative LB0 MUST be Core-total group_M.
// For every cooperative Shared-input TMATMUL, LB0 MUST be Core-total group_M;
// Shared A MUST have shape group_MxK and Shared B MUST have shape KxN.
// Each matrix side independently requires an E8M0 scale exactly when its MX
// input type is not FP16 or BF16. Bias is one Local row-major 1xN accumulator-
// type source. Published Shared operands may replace the right group or both
// matrix groups; supplementary operands and destinations remain Local.
// Shared primaries MUST satisfy hardware-maintained whole-parent readiness and publication before payload access; fixed-quarter allocation or initialization masks are not prerequisites.
// TransA/TransB MUST apply only to the corresponding Shared primary. Every
// cooperative nonzero PE mask MUST be 1111; zero-row PEs MUST have no Local effect.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// CCTRL[0]=1 MUST publish raw accumulator-type D and MAY provide a
// non-binding transparent-cache replacement hint; D allocation and
// publication remain mandatory.
// CCTRL[1] MUST be zero for this init=1 form.
// Cache behavior MUST NOT alter results, faults, source lifetime, or ordering.
// NDF-END: PTO-TMATMUL-MX-BIAS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL_MX_BIAS()
    => TileOperation
begin
    return TileOperation_TMATMUL_MX_BIAS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractCubeFunction_TMATMUL_MX_BIAS()
    => integer {0..31}
begin
    return 5;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL_MX_BIAS()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL_MX_BIAS(
    destination: TileIndex,
    left: TileIndex,
    row_scale: TileIndex,
    right: TileIndex,
    column_scale: TileIndex,
    bias: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL_MX_BIAS(
        destination,
        left,
        row_scale,
        right,
        column_scale,
        bias);
end;

readonly func InstructionContractHandler_TMATMUL_MX_BIAS()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_BIAS;
end;
// DOC-END: operation
