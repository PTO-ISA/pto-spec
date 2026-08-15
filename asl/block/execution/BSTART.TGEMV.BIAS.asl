// PTO-INSTRUCTION: {"assembly":["BSTART.TGEMV.BIAS DataType"],"block":[],"catalog_indices":[36],"catalog_records":[{"asm":"BSTART.TGEMV.BIAS DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x01131181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_tgemv_bias_32_186ee96c0a8b","length_bits":32,"mnemonic":"BSTART.TGEMV.BIAS","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Starts CUBE Function 17 for the TGEMV_BIAS M=1 Matrix-vector complete-bundle operation.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.TGEMV.BIAS AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)","B.DIM LB0 M (optional, default 1; TGEMV permits only M=1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOT ordered Local mathematical sources: A matrix, B matrix, 1xN Bias","B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["BSTART.TGEMV.BIAS DataType"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0, LB1, and LB2 default M, N, and K independently to one; TGEMV fixes M to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them."],"encoding_class":"standalone-encoded","examples":["BSTART.TGEMV.BIAS AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1; TGEMV permits only M=1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOT ordered Local mathematical sources: A matrix, B matrix, 1xN Bias; B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["The carrier selects exactly CUBE Function 17 and TileOperation_TGEMV_BIAS.","AType and BType must be supported ordinary Matrix types from one numeric class. Bias is one Local row-major 1xN accumulator-type source. M is fixed to one and every Shared binding is illegal.","Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema."],"memory_effects":["none"],"operands":[{"field":"DataType","role":"tile element data type selector"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist."],"standalone_opcode":true,"state_effects":["Start a CUBE Function 17 descriptor with encoded DataType preserved as AType.","At block completion execute TileOperation_TGEMV_BIAS using the resolved M, N, K, input types, mathematical operands, and B.FPATR postprocess schema.","Publish the complete output group atomically after successful preflight and computation; do not consume mathematical or postprocess sources."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-TGEMV-BIAS","mnemonic":"BSTART.TGEMV.BIAS","summary":"Starts CUBE Function 17 for the TGEMV_BIAS M=1 Matrix-vector complete-bundle operation.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-TGEMV-BIAS-CONTRACT-001
// ndf: kind=contract level=L1 layer=block status=accepted
// BSTART.TGEMV.BIAS MUST select CUBE Function 17 and TileOperation_TGEMV_BIAS.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// and every resolved dimension MUST be a nonzero power of two.
// AType and BType must be supported ordinary Matrix types from one numeric
// class. Bias is one Local row-major 1xN accumulator-type source. M is fixed
// to one and every Shared binding is illegal.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// NDF-END: PTO-BSTART-TGEMV-BIAS-CONTRACT-001


// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_TGEMV_BIAS(
    operation: CommandOperation) => boolean
begin
    return operation ==
        CommandOperation_bstart_tgemv_bias_32_186ee96c0a8b;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractTileOperation_BSTART_TGEMV_BIAS()
    => TileOperation
begin
    return TileOperation_TGEMV_BIAS;
end;

readonly func InstructionContractCubeFunction_BSTART_TGEMV_BIAS()
    => integer {0..31}
begin
    return 17;
end;

readonly func InstructionContractSharedOperandsAllowed_BSTART_TGEMV_BIAS()
    => boolean
begin
    return FALSE;
end;

readonly func InstructionContractHandler_BSTART_TGEMV_BIAS()
    => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
// DOC-END: operation
