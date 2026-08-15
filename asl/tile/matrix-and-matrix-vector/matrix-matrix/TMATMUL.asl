// PTO-INSTRUCTION: {"assembly":["TMATMUL <bundle operands>"],"block":["BSTART.TMATMUL AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)","B.DIM LB0 M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; executing mask 1111)","B.IOT ordered Local mathematical sources: A matrix, B matrix","B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"catalog_indices":[97],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TMATMUL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["DataType","RMode","Sat"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMATMUL","family":"CUBE","fault_contract":"ExecuteTileInstruction","function":0,"legality_handler":"TileOperandsLegal_TMATMUL","name":"TMATMUL","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMATMUL","state_effects":["operand:destination0:destination","operand:source0:left","operand:source1:right"]}],"classification":["matrix-and-matrix-vector","matrix-matrix"],"contract":{"block_composition":["BSTART.TMATMUL AType","B.DATR BType, RMode, Sat (optional; BType defaults to AType)","B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one)","B.DIM LB0 M (optional, default 1)","B.DIM LB1 N (optional, default 1)","B.DIM LB2 K (optional, default 1)","B.IOS complete right or both matrix operand groups (optional; executing mask 1111)","B.IOT ordered Local mathematical sources: A matrix, B matrix","B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations","B.IOT/B.IOR postprocess operands selected by B.FPATR","BSTOP or the next BSTART completion boundary"],"canonical_assembly":["TMATMUL <bundle operands>"],"defaults":["Encoded DataType is always AType. Omitted B.DATR preserves AType as BType, selects RNE, and disables saturation.","Omitted LB0, LB1, and LB2 default M, N, and K independently to one.","Exactly one all-zero B.FPATR selects no conversion, activation, or reduction; B.IOR and auxiliary B.IOT operands exist only when a selected postprocess mode requires them."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TMATMUL AType; B.DATR BType, RMode, Sat (optional; BType defaults to AType); B.FPATR PreQuantMode, ReluMode, GroupNCode, RowMaxEn, GroupMaxEn, RowMaxInit, MaxAbsEn (exactly one); B.DIM LB0 M (optional, default 1); B.DIM LB1 N (optional, default 1); B.DIM LB2 K (optional, default 1); B.IOS complete right or both matrix operand groups (optional; executing mask 1111); B.IOT ordered Local mathematical sources: A matrix, B matrix; B.IOT D, optional RowMaxOut, optional GroupMaxOut destinations; B.IOT/B.IOR postprocess operands selected by B.FPATR; BSTOP or the next BSTART completion boundary"],"exceptions":["A reserved DataType or fixed-bit mismatch raises Fault_IllegalInstruction before block state changes.","Missing, duplicate, or non-Matrix B.FPATR use raises Fault_BundleControl before allocation or payload effects.","Illegal types, dimensions, masks, binding streams, descriptors, shapes, capacities, aliases, readiness, or postprocess values raise Fault_TileLegality before source snapshots and effects."],"field_contracts":{},"field_zero_meanings":{},"legality":["The carrier selects exactly CUBE Function 0 and TileOperation_TMATMUL.","AType and BType must be supported ordinary Matrix types from one numeric class. Published Shared operands may replace the right group or both matrix groups; supplementary operands and destinations remain Local.","Every executing Local or Shared binding uses PE_MASK=1111; mask zero is a strict no-op before descriptor reads, faults, allocation, readiness checks, or lifetime effects.","B.DATR permits only BType, RMode, and Sat. Exactly one B.FPATR is mandatory and closes the conditional postprocess schema."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"left"},{"field":"source1","role":"right"}],"ordering":["Complete schema, field, type, dimension, descriptor, shape, capacity, readiness, alias, and allocation preflight precedes every source snapshot and destination effect.","D and every enabled reduction output publish as one atomic group; rejection publishes none and successful sources persist."],"standalone_opcode":false,"state_effects":["Multiply A[M x K] by B[K x N] into one private FP32, S32, or U32 CUBE destination.","After complete preflight, execute TMATMUL with the operand bindings listed above; destination definedness changes only as specified by that handler."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"CUBE","id":"PTO-TILE-TMATMUL","mnemonic":"TMATMUL","summary":"Multiply A[M x K] by B[K x N] into one private FP32, S32, or U32 CUBE destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMATMUL-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TMATMUL MUST select CUBE Function 0 and TileOperation_TMATMUL.
// Its encoded DataType is AType; omitted B.DATR MUST preserve AType as
// BType, omitted LB0/LB1/LB2 MUST default M/N/K independently to one,
// and every resolved dimension MUST be a nonzero power of two.
// AType and BType must be supported ordinary Matrix types from one numeric
// class. Published Shared operands may replace the right group or both matrix
// groups; supplementary operands and destinations remain Local.
// Exactly one B.FPATR MUST close postprocess defaults and operands.
// Complete schema, type, shape, capacity, definedness, readiness, alias,
// and allocation preflight MUST precede source snapshots and effects;
// successful outputs MUST publish atomically and sources MUST persist.
// NDF-END: PTO-TMATMUL-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMATMUL()
    => TileOperation
begin
    return TileOperation_TMATMUL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractCubeFunction_TMATMUL()
    => integer {0..31}
begin
    return 0;
end;

readonly func InstructionContractSharedOperandsAllowed_TMATMUL()
    => boolean
begin
    return TRUE;
end;

readonly func InstructionContractOperandsLegal_TMATMUL(
    destination: TileIndex,
    left: TileIndex,
    right: TileIndex) => boolean
begin
    return TileOperandsLegal_TMATMUL(
        destination,
        left,
        right);
end;

readonly func InstructionContractHandler_TMATMUL()
    => TileSemanticHandler
begin
    return TileHandler_TMATMUL;
end;
// DOC-END: operation
