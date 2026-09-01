// PTO-INSTRUCTION: {"assembly":["TCMPS <bundle operands>"],"block":["BSTART.VEC TCMPS, DataType","B.DATR CMode, PadValue, SatMode (U8 GPR form only)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination","B.IOR scalar-compare source and optional predicate-GPR destination","BSTOP"],"catalog_indices":[37],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"comparison"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["CMode","PadValueOrByteId","Sat"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileCompareScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_ExecuteTileCompareScalar","mode":1,"name":"TCMPS","operands":[{"field":"destination0","role":"legacy Predicate or CUBE PredicateCell destination; absent for GPR carrier"},{"field":"source0","role":"persistent Local numeric source"},{"field":"scalar0","role":"per-participating-PE private-GPR scalar"},{"field":"comparison","role":"six-mode comparison"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x02D","semantic_handler":"ExecuteTileCompareScalar","state_effects":["operand:destination0:variant-predicate-carrier-destination","operand:source0:persistent-local-source","operand:scalar0:private-gpr-raw-element","operand:comparison:six-mode-comparison","runtime:CurrentBundlePadValue:predicate-padding"]}],"classification":["tile-scalar-and-immediate","logical"],"contract":{"block_composition":["BSTART.VEC TCMPS, DataType","B.DATR CMode, PadValue, SatMode (U8 GPR form only)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination","B.IOR scalar-compare source and optional predicate-GPR destination","BSTOP"],"canonical_assembly":["TCMPS <bundle operands>"],"defaults":["CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE; codes 6 and 7 are reserved. Omitted B.DATR selects EQ.","LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.","Omitted B.IOR supplies the selected source DataType all-zero scalar encoding. Omitted PadValue selects Null predicate padding."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TCMPS, DataType; B.DATR CMode, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->Predicate<TSize>; B.IOR ScalarGPR, zero, zero, ->zero (optional); BSTOP"],"exceptions":["Malformed or mixed carrier schemas, missing dimensions, reserved CMode, unsupported DataType, undefined or invalid source/scalar data, insufficient PredicateCell capacity, or allocation failure rejects before effects.","Signaling floating NaN status publishes atomically with the selected GPR or PredicateCell result."],"field_contracts":{"B.DATR.CMode":{"ref":"PTO-FIELD-BLOCK-CMODE"},"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.CMode":"EQ.","B.DATR.PadValueOrByteId":"Zero predicate padding when present; omission selects Null.","B.IOR.RegSrc0":"Architectural zero register."},"legality":["TCMPS selects TEPL Mode 1 Function 13 and executes on VEC. PE_MASK=0000 is a strict no-op before GPR, source, allocation, status, or payload checks.","Legacy RowMajor form uses one terminating B.IOT with source and new packed Predicate destination; one optional B.IOR supplies the compare scalar.","CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with source and new basis-tagged U8 PredicateCell destination plus an optional scalar-source B.IOR; omission selects zero. The source type is exactly one of FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8.","CUBE_M16/M32 GPR form uses one source-only B.IOT and one B.IOR carrying the scalar source plus one destination GPR. The source type is 32-bit or 16-bit types from the closed CUBE domain, plus U8; U8 Sat selects Low or High columns.","Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. CMode and PadValue apply to all; Sat is nonzero only for U8 GPR selection; Canonicalize remains zero."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"legacy packed Predicate or CUBE PredicateCell destination; absent for GPR producer"},{"field":"source0","role":"persistent Local numeric source"},{"field":"scalar0","role":"per-participating-PE compare scalar"},{"field":"comparison","role":"six-mode comparison"}],"ordering":["Complete schema, dimensions, attributes, type, source, scalar, predicate capacity, mask, and allocation preflight precedes source and scalar snapshots.","The source payload and scalar are snapshotted before packed destination publication."],"standalone_opcode":false,"state_effects":["Each valid comparison publishes through the selected carrier: legacy low-first packed bit, canonical PredicateCell byte, or GPR predicate bit.","Zero and Min padding write zero predicate bits, Max writes one bits, and Null leaves padding undefined.","Selected carrier payload, padding, numeric status, and descriptor or GPR result publish atomically; rejection has no architectural effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TCMPS","mnemonic":"TCMPS","summary":"Compare each valid Local Tile element with a scalar and produce one legacy Predicate, CUBE PredicateCell, or GPR carrier.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCMPS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCMPS MUST compare one Local numeric source with the selected scalar, where
// omitted B.IOR supplies the all-zero scalar, and MUST accept only CMode 0
// through 5. The legacy RowMajor form MUST pack predicate i into bit i mod 8
// of byte floor(i/8). A CUBE form MUST publish either canonical basis-matched
// PredicateCell bytes or one complete GPR predicate word. The three carriers
// MUST be mutually exclusive, and scalar-input and GPR-result roles MUST remain
// distinct. Complete legality preflight MUST precede snapshots and atomic
// carrier, padding, status, and descriptor publication.
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
