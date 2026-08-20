// PTO-INSTRUCTION: {"assembly":["BSTART.TGEMV.ACC DataType"],"block":[],"catalog_indices":[35],"catalog_records":[{"asm":"BSTART.TGEMV.ACC DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x01231181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tgemv_acc_32_9a471b21913e","length_bits":32,"mnemonic":"BSTART.TGEMV.ACC","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts CUBE Function 18 for the TGEMV_ACC M=1 Matrix-vector complete-bundle operation.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.TGEMV.ACC AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)","B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A, A CUBE_M16/M32 primary, B CUBE_N8 primary","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["BSTART.TGEMV.ACC DataType"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize."],"encoding_class":"standalone-encoded","examples":["BSTART.TGEMV.ACC AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: C CUBE_M16/M32 accumulator matching A, A CUBE_M16/M32 primary, B CUBE_N8 primary; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["The carrier selects exactly CUBE Function 18 and TileOperation_TGEMV_ACC.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout; Local C also uses A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize.","AType and BType must be supported ordinary Matrix types from one numeric class. C is one explicit Local MxN accumulator source and D is a newly published destination; C and D may use one architectural Tile name. M is fixed to one and every Shared binding is illegal.","Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema."],"memory_effects":["none"],"operands":[{"field":"DataType","role":"tile element data type selector"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist."],"standalone_opcode":true,"state_effects":["Start a CUBE Function 18 descriptor with encoded DataType preserved as AType.","At block completion execute TileOperation_TGEMV_ACC using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.","Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.","For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-TGEMV-ACC","mnemonic":"BSTART.TGEMV.ACC","summary":"Starts CUBE Function 18 for the TGEMV_ACC M=1 Matrix-vector complete-bundle operation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-TGEMV-ACC-CONTRACT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.TGEMV.ACC MUST select CUBE Function 18 and TileOperation_TGEMV_ACC.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// Local N and K MUST be positive and independent of per-PE TSize; M
// MUST equal one.
// AType and BType must be supported ordinary Matrix types from one numeric
// class. C is one explicit Local MxN accumulator source and D is a newly
// published destination; C and D may use one architectural Tile name. M is
// fixed to one and every Shared binding is illegal.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// NDF-END: PTO-BSTART-TGEMV-ACC-CONTRACT-001


// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TGEMV_ACC(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tgemv_acc_32_9a471b21913e;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractTileOperation_BSTART_TGEMV_ACC()
    => TileOperation
begin
    return TileOperation_TGEMV_ACC;
end;

readonly func InstructionContractCubeFunction_BSTART_TGEMV_ACC()
    => integer {0..31}
begin
    return 18;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TGEMV_ACC()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractHandler_BSTART_TGEMV_ACC()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
