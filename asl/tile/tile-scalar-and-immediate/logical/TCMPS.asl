// PTO-INSTRUCTION: {"assembly":["TCMPS <bundle operands>"],"block":["BSTART.VEC TCMPS, DataType","B.DATR CMode, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>","B.IOR ScalarGPR, zero, zero, ->zero (optional)","BSTOP"],"catalog_indices":[37],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"comparison"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["CMode","PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileCompareScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_ExecuteTileCompareScalar","mode":1,"name":"TCMPS","operands":[{"field":"destination0","role":"new packed Local predicate destination"},{"field":"source0","role":"persistent Local numeric source"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"},{"field":"comparison","role":"six-mode comparison"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x02D","semantic_handler":"ExecuteTileCompareScalar","state_effects":["operand:destination0:packed-predicate-destination","operand:source0:persistent-local-source","operand:scalar0:private-gpr-raw-element","operand:comparison:six-mode-comparison","runtime:CurrentBundlePadValue:predicate-padding"]}],"classification":["tile-scalar-and-immediate","logical"],"contract":{"block_composition":["BSTART.VEC TCMPS, DataType","B.DATR CMode, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>","B.IOR ScalarGPR, zero, zero, ->zero (optional)","BSTOP"],"canonical_assembly":["TCMPS <bundle operands>"],"defaults":["CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE; codes 6 and 7 are reserved. Omitted B.DATR selects EQ.","LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.","Omitted B.IOR supplies the selected source DataType all-zero scalar encoding. Omitted PadValue selects Null predicate padding."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TCMPS, DataType; B.DATR CMode, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP"],"exceptions":["Malformed bindings, B.IOS presence, surplus B.IOR fields, reserved CMode, unsupported DataType, undefined or invalid source encoding, predicate capacity failure, or allocation failure raises Fault_TileLegality or Fault_TileAllocation before effects.","Signaling floating NaN records invalid only with the atomically published predicate destination.","CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion after an accepted operation."],"field_contracts":{"B.DATR.CMode":{"ref":"PTO-FIELD-BLOCK-CMODE"},"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.CMode":"EQ.","B.DATR.PadValueOrByteId":"Zero predicate padding when present; omission selects Null.","B.IOR.RegSrc0":"Architectural zero register."},"legality":["TCMPS is selected only by the TEPL raw carrier Mode 1 Function 13 and executes on VEC.","Exactly one terminating Local B.IOT supplies one persistent numeric source and one new packed predicate destination. B.IOS and additional Tile bindings are illegal.","The source DataType is exactly S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8; every other type rejects before effects.","The source is row-major and completely defined. The predicate destination has matching logical geometry and capacity of at least ceil(Row*Col/8) bytes.","Only CMode and PadValueOrByteId are applicable in B.DATR. When B.IOR is present, only RegSrc0 may be nonzero.","PE_MASK=0000 is a strict no-op before GPR, source, allocation, status, or payload checks."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new packed Local predicate destination"},{"field":"source0","role":"persistent Local numeric source"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"},{"field":"comparison","role":"six-mode comparison"}],"ordering":["Complete schema, dimensions, attributes, type, source, scalar, predicate capacity, mask, and allocation preflight precedes source and scalar snapshots.","The source payload and scalar are snapshotted before packed destination publication."],"standalone_opcode":false,"state_effects":["Logical element i publishes its comparison result in bit i mod 8 of byte floor(i/8), with low logical indices in low bits.","Zero and Min padding write zero predicate bits, Max writes one bits, and Null leaves padding undefined.","Packed payload, padding definedness, numeric status, and destination descriptor publish atomically; rejection has no architectural effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TCMPS","mnemonic":"TCMPS","summary":"Compare each valid Local Tile element with one private-GPR scalar and produce a packed predicate Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCMPS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCMPS MUST compare one Local numeric source with one private-GPR scalar,
// MUST accept only CMode 0 through 5, and MUST pack logical predicate i into
// bit i mod 8 of byte floor(i/8). Complete legality and allocation preflight
// MUST precede source/scalar snapshots and atomic predicate publication.
// NDF-END: PTO-TCMPS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCMPS() => TileOperation
begin
    return TileOperation_TCMPS;
end;

pure func InstructionContractComparisonCodeLegal_TCMPS(
    comparison_code: bits(3)) => boolean
begin
    return UInt(comparison_code) <= 5;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TCMPS(
    data_type: TileDataType) => boolean
begin
    return TileCompareDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCMPS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word,
    comparison: TileComparison) => boolean
begin
    return TileOperandsLegal_ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
end;

readonly func InstructionContractHandler_TCMPS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompareScalar;
end;

func InstructionContractExecute_TCMPS(
    destination: TileIndex,
    source: TileIndex,
    scalar: Word,
    comparison: TileComparison)
begin
    assert InstructionContractOperandsLegal_TCMPS(
        destination,
        source,
        scalar,
        comparison);
    ExecuteTileCompareScalar(
        destination,
        source,
        scalar,
        comparison);
end;
// DOC-END: operation
