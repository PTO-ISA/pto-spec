// PTO-INSTRUCTION: {"assembly":["BSTART.TMATMUL.ACC DataType"],"block":[],"catalog_indices":[42],"catalog_records":[{"asm":"BSTART.TMATMUL.ACC DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00231181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tmatmul_acc_32_0c8c62e5f00a","length_bits":32,"mnemonic":"BSTART.TMATMUL.ACC","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts CUBE Function 2 for the TMATMUL_ACC Matrix-matrix complete-bundle operation.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.TMATMUL.ACC AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB (exactly one)","B.DIM LB0 M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; common nonzero mask)","B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A, A CUBE_M16/M32 primary, B CUBE_N8 primary","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["BSTART.TMATMUL.ACC DataType"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0, LB1, and LB2 default M, N, and K independently to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize.","TransA=0 and TransB=0 select no logical transpose. Each nonzero control is legal only when the corresponding primary is Shared."],"encoding_class":"standalone-encoded","examples":["BSTART.TMATMUL.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB (exactly one); B.DIM LB0 M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; common nonzero mask); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A, A CUBE_M16/M32 primary, B CUBE_N8 primary; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["The carrier selects exactly CUBE Function 2 and TileOperation_TMATMUL_ACC.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M, N, and K are arbitrary positive values independent of per-PE TSize.","A Shared primary must be fully published with all four fixed quarters ready. TransA and TransB apply only to their corresponding Shared primary. Right-only Shared inherits Local A layout; all-Shared ACC inherits C layout; all-Shared non-ACC selects M16 through M=16 and M32 through M=32.","AType and BType must be supported ordinary Matrix types from one numeric class. C is one explicit Local MxN accumulator source and D is a newly published destination; C and D may use one architectural Tile name. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.","Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema."],"memory_effects":["none"],"operands":[{"field":"DataType","role":"tile element data type selector"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist."],"standalone_opcode":true,"state_effects":["Start a CUBE Function 2 descriptor with encoded DataType preserved as AType.","At block completion execute TileOperation_TMATMUL_ACC using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.","Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.","For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.","Successful Shared primary reads leave every Shared descriptor, mask, publication state, payload, and lifetime unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-TMATMUL-ACC","mnemonic":"BSTART.TMATMUL.ACC","summary":"Starts CUBE Function 2 for the TMATMUL_ACC Matrix-matrix complete-bundle operation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-TMATMUL-ACC-CONTRACT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.TMATMUL.ACC MUST select CUBE Function 2 and TileOperation_TMATMUL_ACC.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// and every Local M/N/K MUST be positive and independent of per-PE
// TSize. The current Shared path retains its existing dimension rule.
// AType and BType must be supported ordinary Matrix types from one numeric
// class. C is one explicit Local MxN accumulator source and D is a newly
// published destination; C and D may use one architectural Tile name.
// Published Shared operands may replace the right group or both matrix groups;
// supplementary operands and destinations remain Local.
// Shared primaries MUST be fully published and ready in all four fixed quarters.
// TransA/TransB MUST apply only to the corresponding Shared primary, and every
// common nonzero PE mask MUST publish only selected Local outputs.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// NDF-END: PTO-BSTART-TMATMUL-ACC-CONTRACT-001


// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TMATMUL_ACC(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tmatmul_acc_32_0c8c62e5f00a;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractTileOperation_BSTART_TMATMUL_ACC()
    => TileOperation
begin
    return TileOperation_TMATMUL_ACC;
end;

readonly func InstructionContractCubeFunction_BSTART_TMATMUL_ACC()
    => integer {0..31}
begin
    return 2;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TMATMUL_ACC()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractHandler_BSTART_TMATMUL_ACC()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
