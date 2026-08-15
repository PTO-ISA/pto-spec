// PTO-INSTRUCTION: {"assembly":["TSUBS <bundle operands>"],"block":["BSTART.VEC TSUBS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR ScalarGPR, zero, zero, ->zero (optional)","BSTOP"],"catalog_indices":[26],"catalog_records":[{"arguments":[{"constant":"TileBinary_SUB"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":1,"legality_handler":"TileOperandsLegal_ExecuteTileScalar","mode":1,"name":"TSUBS","operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"source0","role":"persistent Local numeric source"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x021","semantic_handler":"ExecuteTileScalar","state_effects":["operand:destination0:new-local-numeric-destination","operand:source0:persistent-local-source","operand:scalar0:private-gpr-raw-element","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["tile-scalar-and-immediate","arithmetic"],"contract":{"block_composition":["BSTART.VEC TSUBS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR ScalarGPR, zero, zero, ->zero (optional)","BSTOP"],"canonical_assembly":["TSUBS <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","Omitted B.IOR supplies scalar zero. An explicitly present all-zero B.IOR is distinct but supplies the same value; RegSrc1, RegSrc2, and RegDst must be zero."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TSUBS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP"],"exceptions":["A malformed Local binding stream, B.IOS presence, surplus B.IOR field, missing or zero dimension, unsupported DataType, source descriptor or encoding failure, invalid destination capacity, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.","Operand order is always Tile source minus scalar; floating results follow the profile and integer results wrap at the element width.","CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.IOR.RegSrc0":"The architectural zero register."},"legality":["TSUBS is selected only by the TEPL raw carrier Mode 1 Function 1; canonical execution-engine assembly is BSTART.VEC TSUBS, DataType.","Exactly one terminating Local B.IOT supplies one persistent Local numeric source and one newly allocated Local destination. B.IOS and additional Tile bindings are illegal.","The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8; every other assigned or reserved DataType rejects before effects.","Source and destination match physical shape, valid shape, row-major layout, and DataType. Every valid source element is defined and every constrained floating encoding is valid.","B.IOR is optional and, when present, only RegSrc0 may be nonzero. PadValueOrByteId is the only applicable B.DATR field; explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before GPR reads, descriptor reads, allocation, faults, numeric status, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"source0","role":"persistent Local numeric source"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"}],"ordering":["Complete schema, attribute, dimension, type, descriptor, source-definedness, scalar-encoding, mask, capacity, and allocation preflight precedes source and scalar snapshots.","The source payload and scalar are snapshotted before destination publication, so a source that aliases the renamed destination observes its old value."],"standalone_opcode":false,"state_effects":["For each valid element compute source - scalar in the selected element interpretation.","Publish valid payload, selected padding definedness, numeric status where applicable, and destination descriptor atomically; the source persists and rejection has no architectural effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TSUBS","mnemonic":"TSUBS","summary":"Subtract one private-GPR scalar from every valid element of a Local Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSUBS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSUBS MUST consume one Local source, one per-participating-PE
// private-GPR scalar from optional B.IOR.RegSrc0, and one renamed Local
// destination, and MUST compute source - scalar over the valid region.
// The selected DataType MUST satisfy TileVecArithmeticDataTypeSupported; only
// PadValueOrByteId is applicable in B.DATR. Complete legality and
// allocation preflight MUST precede source/scalar snapshots and atomic
// payload, padding, status, and descriptor publication.
// NDF-END: PTO-TSUBS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSUBS() => TileOperation
begin
    return TileOperation_TSUBS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TSUBS(
    data_type: TileDataType) => boolean
begin
    return TileBinaryDataTypeSupported(
        TileBinary_SUB,
        data_type);
end;

readonly func InstructionContractOperandsLegal_TSUBS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileScalar(
        TileBinary_SUB,
        destination,
        source,
        scalar);
end;

readonly func InstructionContractHandler_TSUBS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;

func InstructionContractExecute_TSUBS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TSUBS(
        destination,
        source,
        scalar);
    ExecuteTileScalar(
        TileBinary_SUB,
        destination,
        source,
        scalar);
end;
// DOC-END: operation
