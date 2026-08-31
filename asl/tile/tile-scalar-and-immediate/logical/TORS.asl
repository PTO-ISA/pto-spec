// PTO-INSTRUCTION: {"assembly":["TORS <bundle operands>"],"block":["BSTART.VEC TORS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR ScalarGPR, zero, zero, ->zero (optional)","BSTOP"],"catalog_indices":[31],"catalog_records":[{"arguments":[{"constant":"TileBinary_OR"},{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_ExecuteTileScalar","mode":1,"name":"TORS","operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"source0","role":"persistent Local numeric source"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x027","semantic_handler":"ExecuteTileScalar","state_effects":["operand:destination0:new-local-numeric-destination","operand:source0:persistent-local-source","operand:scalar0:private-gpr-raw-element","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["tile-scalar-and-immediate","logical"],"contract":{"block_composition":["BSTART.VEC TORS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR ScalarGPR, zero, zero, ->zero (optional)","BSTOP"],"canonical_assembly":["TORS <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","Omitted B.IOR supplies zero and therefore preserves every valid source encoding. An explicitly present all-zero B.IOR is distinct but supplies the same value; RegSrc1, RegSrc2, and RegDst must be zero."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TORS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP"],"exceptions":["A malformed Local binding stream, B.IOS presence, surplus B.IOR field, missing or zero dimension, unsupported DataType, source descriptor, definedness, or carrier-width failure, invalid destination capacity, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.","Only the low element width participates; signedness does not change the raw operation and no numeric-status flag is produced.","CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.IOR.RegSrc0":"The architectural zero register."},"legality":["TORS is selected only by the TEPL raw carrier Mode 1 Function 7; canonical execution-engine assembly is BSTART.VEC TORS, DataType.","Exactly one terminating Local B.IOT supplies one persistent Local numeric source and one newly allocated Local destination. B.IOS and additional Tile bindings are illegal.","The selected DataType is exactly S64, S32, S16, S8, U64, U32, U16, or U8; every other assigned or reserved DataType rejects before effects.","B.IOR is optional and, when present, only RegSrc0 may be nonzero. PadValueOrByteId is the only applicable B.DATR field; explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","Source and destination use one PE_MASK. PE_MASK=0000 is a strict no-op before GPR reads, descriptor reads, allocation, faults, numeric status, or payload effects.","The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"source0","role":"persistent Local numeric source"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"}],"ordering":["Complete schema, attribute, dimension, type, descriptor, source-definedness, scalar-encoding, mask, capacity, and allocation preflight precedes source and scalar snapshots.","The source payload and scalar are snapshotted before destination publication, so a source that aliases the renamed destination observes its old value."],"standalone_opcode":false,"state_effects":["For each valid element compute source OR scalar in the selected element interpretation.","Publish valid payload, selected padding definedness, numeric status where applicable, and destination descriptor atomically; the source persists and rejection has no architectural effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TORS","mnemonic":"TORS","summary":"Bitwise-OR every valid integer Tile element with one scalar.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TORS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TORS MUST consume one Local source, one per-participating-PE
// private-GPR scalar from optional B.IOR.RegSrc0, and one renamed Local
// destination, and MUST compute source OR scalar over the valid region.
// The selected DataType MUST satisfy TileVecScalarIntegerDataTypeSupported; only
// PadValueOrByteId is applicable in B.DATR. Complete legality and
// allocation preflight MUST precede source/scalar snapshots and atomic
// payload, padding, status, and descriptor publication.
// The selected DataType MUST be the operation interpretation and new destination
// backing type. An ordinary source backing type MAY differ only for a same-width
// non-packed carrier; numeric validation MUST use the selected DataType.
// NDF-END: PTO-TORS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TORS() => TileOperation
begin
    return TileOperation_TORS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TORS(
    data_type: TileDataType) => boolean
begin
    return TileVecScalarIntegerDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TORS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileScalar(
        TileBinary_OR,
        destination,
        source,
        scalar);
end;

readonly func InstructionContractHandler_TORS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;

func InstructionContractExecute_TORS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word)
begin
    assert InstructionContractOperandsLegal_TORS(
        destination,
        source,
        scalar);
    ExecuteTileScalar(
        TileBinary_OR,
        destination,
        source,
        scalar);
end;
// DOC-END: operation
