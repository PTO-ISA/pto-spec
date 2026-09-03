// PTO-INSTRUCTION: {"assembly":["BSTART.TGEMVMX DataType"],"block":[],"catalog_indices":[37],"catalog_records":[{"asm":"BSTART.TGEMVMX DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x01431181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tgemvmx_32_ae5e005f6589","length_bits":32,"mnemonic":"BSTART.TGEMVMX","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts CUBE Function 20 for the TGEMV_MX M=1 Matrix-vector complete-bundle operation.","status":"accepted","state_effects":["runtime:CurrentBundleCCTRL:raw-partial-and-transparent-cache-hints"]}],"classification":["execution"],"contract":{"block_composition":["BSTART.TGEMVMX AType","B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one)","B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale","B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["BSTART.TGEMVMX DataType"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.","TransA=0 and TransB=0 select no logical transpose. TGEMV requires both controls to remain zero.","Omitted CCTRL selects 00: final D output and no transparent-cache hint."],"encoding_class":"standalone-encoded","examples":["BSTART.TGEMVMX AType; B.DATR BType, PadValueOrByteId/CCTRL, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn, TransA, TransB, CScaleEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: A CUBE_M16/M32 primary, optional A scale, B CUBE_N8 primary, optional B scale; B.IOT D matching A's CUBE_M16/M32 layout, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["The carrier selects exactly CUBE Function 20 and TileOperation_TGEMV_MX.","Local A uses persistent CUBE_M16 or CUBE_M32, Local B uses persistent CUBE_N8, and D is newly allocated in A's M layout. M is fixed to one; N and K are arbitrary positive values independent of per-PE TSize. Required E8M0 scales remain ordinary row-major Tiles.","TGEMV is Local-only: TransA and TransB are zero and every effective Shared binding rejects before effects.","Each matrix side independently requires an E8M0 scale exactly when its MX input type is not FP16 or BF16. M is fixed to one and every Shared binding is illegal.","Every common nonzero four-bit PE_MASK is legal; all four PEs complete cooperative Shared readiness while only selected PEs allocate and publish. Mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits BType, matrix CCTRL via PadValueOrByteId, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema.","For init=1 forms CCTRL[1] must be zero. CCTRL[0]=1 selects raw accumulator-type D and forbids final-output post-processing and auxiliary outputs except legal CScale; CCTRL[1] is an ACC-only non-binding explicit-C cache-use or prefetch hint. Every successful form allocates and publishes D."],"memory_effects":["none"],"operands":[{"field":"DataType","role":"tile element data type selector"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist.","Transparent-cache hints occur only after complete preflight and cannot alter source snapshots, D allocation or publication, faults, or numeric status."],"standalone_opcode":true,"state_effects":["Start a CUBE Function 20 descriptor with encoded DataType preserved as AType.","At block completion execute TileOperation_TGEMV_MX using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.","Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources.","For Local execution, publish D with A's CUBE_M16 or CUBE_M32 layout and final output dtype; ordinary Bias, MX scales, and enabled reduction auxiliaries keep their operation-owned layouts.","Always publish D; CCTRL[0]=1 publishes raw accumulator-type D and may hint cache replacement, while ACC CCTRL[1]=1 may hint cache use or prefetch of explicit C. Hint handling is not architecturally observable."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-TGEMVMX","mnemonic":"BSTART.TGEMVMX","summary":"Starts CUBE Function 20 for the TGEMV_MX M=1 Matrix-vector complete-bundle operation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-TGEMVMX-CONTRACT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.TGEMVMX MUST select CUBE Function 20 and TileOperation_TGEMV_MX.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// Local N and K MUST be positive and independent of per-PE TSize; M
// MUST equal one.
// Each matrix side independently requires an E8M0 scale exactly when its MX
// input type is not FP16 or BF16. M is fixed to one and every Shared binding
// is illegal.
// TransA and TransB MUST remain zero and every Shared binding MUST reject.
// Every common nonzero Local PE mask is legal; mask zero is a strict no-op.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// CCTRL[0]=1 MUST publish raw accumulator-type D and MAY provide a
// non-binding transparent-cache replacement hint; D allocation and
// publication remain mandatory.
// CCTRL[1] MUST be zero for this init=1 form.
// Cache behavior MUST NOT alter results, faults, source lifetime, or ordering.
// NDF-END: PTO-BSTART-TGEMVMX-CONTRACT-001


// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TGEMVMX(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tgemvmx_32_ae5e005f6589;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractTileOperation_BSTART_TGEMVMX()
    => TileOperation
begin
    return TileOperation_TGEMV_MX;
end;

readonly func InstructionContractCubeFunction_BSTART_TGEMVMX()
    => integer {0..31}
begin
    return 20;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TGEMVMX()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractHandler_BSTART_TGEMVMX()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
