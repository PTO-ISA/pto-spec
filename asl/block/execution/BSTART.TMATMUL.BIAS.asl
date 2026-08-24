// PTO-INSTRUCTION: {"assembly":["BSTART.TMATMUL.BIAS DataType"],"block":[],"catalog_indices":[43],"catalog_records":[{"asm":"BSTART.TMATMUL.BIAS DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00131181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tmatmul_bias_32_4d5a498d12f3","length_bits":32,"mnemonic":"BSTART.TMATMUL.BIAS","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts CUBE Function 1 for the TMATMUL_BIAS Matrix-matrix complete-bundle operation.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.TMATMUL.BIAS AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB (exactly one)","B.DIM LB0 M or cooperative group_M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111)","B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary, 1xN Bias","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["BSTART.TMATMUL.BIAS DataType"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0 defaults Local M or cooperative group_M to one; omitted LB1 and LB2 default N and K to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias remains an ordinary row-major 1xN accumulator-type Tile.","TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared."],"encoding_class":"standalone-encoded","examples":["BSTART.TMATMUL.BIAS AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB (exactly one); B.DIM LB0 M or cooperative group_M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; cooperative mask 1111); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, B CUBE_N8 primary, 1xN Bias; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["The carrier selects exactly CUBE Function 1 and TileOperation_TMATMUL_BIAS.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize. Bias remains an ordinary row-major 1xN accumulator-type Tile.","A Shared primary must be fully published with all four fixed quarters ready. Any cooperative Local-A/Shared-B or Shared-A/Shared-B TMATMUL interprets LB0 as Core-total group_M in 1..128; Shared A has shape group_MxK, Shared B has shape KxN, and PE i uses valid_M=clamp(group_M-i*M_per_PE,0,M_per_PE) with M_per_PE 16 or 32. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.","AType and BType must be supported ordinary Matrix types from one numeric class. Bias is one Local row-major 1xN accumulator-type source. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.","Every cooperative nonzero PE_MASK must be 1111; all four PEs complete Shared readiness, while zero-row PEs suppress every compute-only Local resolution and effect. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema."],"memory_effects":["none"],"operands":[{"field":"DataType","role":"tile element data type selector"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist."],"standalone_opcode":true,"state_effects":["Start a CUBE Function 1 descriptor with encoded DataType preserved as AType.","At block completion execute TileOperation_TMATMUL_BIAS using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.","Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.","For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.","Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-TMATMUL-BIAS","mnemonic":"BSTART.TMATMUL.BIAS","summary":"Starts CUBE Function 1 for the TMATMUL_BIAS Matrix-matrix complete-bundle operation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-TMATMUL-BIAS-CONTRACT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.TMATMUL.BIAS MUST select CUBE Function 1 and TileOperation_TMATMUL_BIAS.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// Local M, N, and K MUST be positive per-PE dimensions independent of TSize;
// cooperative LB0 MUST be Core-total group_M.
// For every cooperative Shared-input TMATMUL, LB0 MUST be Core-total group_M;
// Shared A MUST have shape group_MxK and Shared B MUST have shape KxN.
// AType and BType must be supported ordinary Matrix types from one numeric
// class. Bias is one Local row-major 1xN accumulator-type source. Published
// Shared operands may replace the right group or both matrix groups;
// supplementary operands and destinations remain Local.
// Shared primaries MUST be fully published and ready in all four fixed quarters.
// TransA/TransB MUST apply only to the corresponding Shared primary. Every
// cooperative nonzero PE mask MUST be 1111; zero-row PEs MUST have no Local effect.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// NDF-END: PTO-BSTART-TMATMUL-BIAS-CONTRACT-001


// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TMATMUL_BIAS(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tmatmul_bias_32_4d5a498d12f3;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractTileOperation_BSTART_TMATMUL_BIAS()
    => TileOperation
begin
    return TileOperation_TMATMUL_BIAS;
end;

readonly func InstructionContractCubeFunction_BSTART_TMATMUL_BIAS()
    => integer {0..31}
begin
    return 1;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TMATMUL_BIAS()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractHandler_BSTART_TMATMUL_BIAS()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
