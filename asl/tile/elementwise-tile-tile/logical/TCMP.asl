// PTO-INSTRUCTION: {"assembly":["TCMP <bundle operands>"],"block":["BSTART.VEC TCMP, DataType","B.DATR CMode, PadValue, SatMode (U8 GPR form only)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination","B.IOR predicate-GPR destination (GPR form only)","BSTOP"],"catalog_indices":[12],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"comparison"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["CMode","PadValueOrByteId","Sat"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileCompare","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_ExecuteTileCompare","mode":0,"name":"TCMP","operands":[{"field":"destination0","role":"predicate destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"},{"field":"comparison","role":"comparison"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x00D","semantic_handler":"ExecuteTileCompare","state_effects":["operand:destination0:packed-predicate-destination","operand:source0:persistent-source-left","operand:source1:persistent-source-right","operand:comparison:six-mode-comparison","runtime:CurrentBundlePadValue:predicate-padding"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TCMP, DataType","B.DATR CMode, PadValue, SatMode (U8 GPR form only)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination","B.IOR predicate-GPR destination (GPR form only)","BSTOP"],"canonical_assembly":["TCMP <bundle operands>"],"defaults":["CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE. Codes 6 and 7 are reserved. Omitted B.DATR retains CMode zero and therefore selects EQ.","LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.","Omitted B.DATR selects predicate PadValue=Null. Explicit PadValue 00 and 10 write zero padding bits, 01 writes one padding bits, and 11 leaves padding bits undefined."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TCMP, U64; B.DATR EQ, Null (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->Predicate<TSize>; BSTOP"],"exceptions":["Malformed bindings, B.IOR or B.IOS presence, missing or zero dimensions, reserved CMode, unsupported DataType, mismatched shape, type or layout, undefined source data, invalid floating source encoding, or insufficient packed destination capacity raises Fault_TileLegality or Fault_TileAllocation before architectural effects.","A signaling floating NaN produces the relation result defined for NaN and records the selected profile invalid status only with the atomically published destination.","CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion behavior after an accepted operation.","CUBE_M16 and CUBE_M32 sources select exactly one carrier: a descriptor-tagged U8 PredicateCell destination or one B.IOR destination GPR; mixed or implicit conversion is illegal.","GPR form uses one 64-bit destination GPR in the existing absolute GPR0..GPR23 namespace and the operation-specific Sat bit selects U8 Low/High; Canonicalize remains zero.","CellReg form requires a descriptor-tagged PredicateCell destination with valid bytes exactly 0x00 or 0x01 and uses ordinary CUBE U8 storage."],"field_contracts":{},"field_zero_meanings":{"B.DATR.CMode":"EQ.","B.DATR.PadValueOrByteId":"Zero predicate padding when B.DATR is present; omission selects Null."},"legality":["TCMP is selected only by VEC Mode 0 Function 13 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies two ordered Local numeric sources and one new Local predicate destination. B.IOR, B.IOS, and additional bindings are illegal.","The source DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.","Both sources match physical shape, valid shape, row-major layout, and DataType; every valid source element is defined and every constrained floating encoding is valid.","The destination uses predicate-kind storage with the same Row, Col, ValidRow, and ValidCol. Logical index i occupies bit i mod 8 of byte floor(i/8), and TSize holds at least ceil(Row*Col/8) bytes.","CMode and PadValueOrByteId are the only applicable B.DATR fields. Explicit nondefault Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","All participating Tiles use one PE_MASK. PE_MASK=0000 is a strict no-op before schema, descriptor, source, allocation, status, or payload checks.","CUBE_M16 and CUBE_M32 sources select exactly one carrier: a descriptor-tagged U8 PredicateCell destination or one B.IOR destination GPR; mixed or implicit conversion is illegal.","GPR form uses one 64-bit destination GPR in the existing absolute GPR0..GPR23 namespace and the operation-specific Sat bit selects U8 Low/High; Canonicalize remains zero.","CellReg form requires a descriptor-tagged PredicateCell destination with valid bytes exactly 0x00 or 0x01 and uses ordinary CUBE U8 storage."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new packed Local predicate destination"},{"field":"source0","role":"ordered left Local numeric source"},{"field":"source1","role":"ordered right Local numeric source"},{"field":"comparison","role":"EQ, NE, LT, GT, LE, or GE selected by CMode"}],"ordering":["Complete schema, field, type, geometry, layout, definedness, encoding, mask, and packed-capacity preflight precedes source snapshots and destination allocation.","Both source payloads are snapshotted before comparison, so identical sources and logical source/destination aliases observe read-old values."],"standalone_opcode":false,"state_effects":["Compare corresponding valid elements using signed, unsigned, or selected floating-profile ordering. NaN makes EQ, LT, GT, LE, and GE false and NE true; positive and negative zero compare equal.","Pack one result bit per logical element with lower logical indices in lower byte bits.","Publish predicate payload, padding definedness, numeric status, and destination descriptor atomically. Rejection leaves source and destination architectural state unchanged, and sources persist."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TCMP","mnemonic":"TCMP","summary":"Compare two Local numeric Tiles and produce one packed Local predicate Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCMP-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCMP MUST accept exactly the sixteen numeric source types defined by this
// instruction, MUST reject CMode 6 and 7 before effects, and MUST pack logical
// comparison i into bit i mod 8 of byte floor(i/8). The destination MUST use
// predicate-kind storage with source geometry and sufficient packed capacity.
// Complete legality preflight MUST precede source snapshots, allocation, flag
// updates, and the atomic predicate destination publication.
// NDF-END: PTO-TCMP-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCMP() => TileOperation
begin
    return TileOperation_TCMP;
end;

pure func InstructionContractComparisonCodeLegal_TCMP(
    comparison_code: bits(3)) => boolean
begin
    return UInt(comparison_code) <= 5;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TCMP(
    data_type: TileDataType) => boolean
begin
    return TileCompareDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCMP(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    comparison: TileComparison) => boolean
begin
    return TileOperandsLegal_ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
end;

readonly func InstructionContractHandler_TCMP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompare;
end;

func InstructionContractExecute_TCMP(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    comparison: TileComparison)
begin
    assert InstructionContractOperandsLegal_TCMP(
        destination,
        source_left,
        source_right,
        comparison);
    ExecuteTileCompare(
        destination,
        source_left,
        source_right,
        comparison);
end;
// DOC-END: operation
