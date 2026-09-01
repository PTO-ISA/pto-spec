// PTO-INSTRUCTION: {"assembly":["TCMP <bundle operands>"],"block":["BSTART.VEC TCMP, DataType","B.DATR CMode, PadValue, SatMode (U8 GPR form only)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination","B.IOR predicate-GPR destination (GPR form only)","BSTOP"],"catalog_indices":[12],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"comparison"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["CMode","PadValueOrByteId","Sat"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileCompare","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_ExecuteTileCompare","mode":0,"name":"TCMP","operands":[{"field":"destination0","role":"legacy Predicate or CUBE PredicateCell destination; absent for GPR carrier"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"},{"field":"comparison","role":"comparison"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x00D","semantic_handler":"ExecuteTileCompare","state_effects":["operand:destination0:variant-predicate-carrier-destination","operand:source0:persistent-source-left","operand:source1:persistent-source-right","operand:comparison:six-mode-comparison","runtime:CurrentBundlePadValue:predicate-padding"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TCMP, DataType","B.DATR CMode, PadValue, SatMode (U8 GPR form only)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->PredicateCell<TSize> OR no destination","B.IOR predicate-GPR destination (GPR form only)","BSTOP"],"canonical_assembly":["TCMP <bundle operands>"],"defaults":["CMode codes 0, 1, 2, 3, 4, and 5 select EQ, NE, LT, GT, LE, and GE. Codes 6 and 7 are reserved. Omitted B.DATR retains CMode zero and therefore selects EQ.","LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.","Omitted B.DATR selects predicate PadValue=Null. Explicit PadValue 00 and 10 write zero padding bits, 01 writes one padding bits, and 11 leaves padding bits undefined."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TCMP, U64; B.DATR EQ, Null (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->Predicate<TSize>; BSTOP"],"exceptions":["Malformed or mixed carrier schemas, missing dimensions, reserved CMode, unsupported DataType, mismatched CUBE shape/layout, undefined or invalid source data, insufficient destination capacity, or allocation failure rejects before source reads or effects.","A signaling floating NaN records invalid status only with the atomically published GPR or PredicateCell result."],"field_contracts":{},"field_zero_meanings":{"B.DATR.CMode":"EQ.","B.DATR.PadValueOrByteId":"Zero predicate padding when B.DATR is present; omission selects Null."},"legality":["TCMP selects VEC Mode 0 Function 13. PE_MASK=0000 is a strict no-op before schema, descriptor, source, allocation, GPR, status, or payload checks.","Legacy RowMajor form uses one terminating B.IOT with two numeric sources and one new packed Predicate destination; B.IOR is absent and the existing sixteen-type domain remains unchanged.","CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with two numeric sources and one new U8 PredicateCell destination tagged with the source basis DataType; B.IOR is absent and the source type is exactly one of FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8.","CUBE_M16/M32 GPR form uses one terminating source-only B.IOT plus one destination-only B.IOR. The source type is 32-bit or 16-bit types from the closed CUBE domain, plus U8; one 64-bit GPR is written atomically, and U8 Sat selects Low or High predicate columns.","Legacy, PredicateCell, and GPR carriers are complete and mutually exclusive. CMode and PadValue apply to every form; Sat is nonzero only for U8 GPR selection; Canonicalize, secondary DataType, RMode, and Layout remain zero.","Predicate padding is Zero/Min=0, Max=1, and Null unspecified or undefined according to the selected GPR/PredicateCell carrier."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"legacy packed Predicate or CUBE PredicateCell destination; absent for GPR producer"},{"field":"source0","role":"ordered left Local numeric source"},{"field":"source1","role":"ordered right Local numeric source"},{"field":"comparison","role":"EQ, NE, LT, GT, LE, or GE selected by CMode"}],"ordering":["Complete schema, field, type, geometry, layout, definedness, encoding, mask, and packed-capacity preflight precedes source snapshots and destination allocation.","Both source payloads are snapshotted before comparison, so identical sources and logical source/destination aliases observe read-old values."],"standalone_opcode":false,"state_effects":["Compare corresponding valid source elements under the selected signed, unsigned, or floating relation.","Publish exactly one selected predicate carrier: legacy packed bits, canonical PredicateCell bytes 0x00/0x01 with basis tag, or one 64-bit GPR predicate word.","Payload, predicate padding, numeric status, descriptor/GPR result, and definedness publish atomically; rejection leaves all architectural state unchanged."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TCMP","mnemonic":"TCMP","summary":"Compare two Local numeric Tiles and produce one legacy Predicate, CUBE PredicateCell, or GPR carrier.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCMP-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCMP MUST accept exactly the numeric source types defined by its selected
// carrier form and MUST reject CMode 6 and 7 before effects. The legacy
// RowMajor form MUST pack comparison i into bit i mod 8 of byte floor(i/8) in
// Predicate storage. A CUBE form MUST publish either canonical PredicateCell
// bytes tagged with the source basis DataType and layout, or one complete GPR
// predicate word. The three carriers MUST be mutually exclusive. Complete
// legality preflight MUST precede source snapshots, allocation, flag updates,
// and atomic carrier publication.
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
