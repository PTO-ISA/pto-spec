// PTO-INSTRUCTION: {"assembly":["TSEL <bundle operands>"],"block":["BSTART.VEC TSEL, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Predicate, SrcTrue, mask=PE_MASK","B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[22],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileSelect","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":26,"legality_handler":"TileOperandsLegal_ExecuteTileSelect","mode":0,"name":"TSEL","operands":[{"field":"destination0","role":"numeric destination"},{"field":"source0","role":"packed predicate mask"},{"field":"source1","role":"source-true"},{"field":"source2","role":"source-false"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01A","semantic_handler":"ExecuteTileSelect","state_effects":["operand:destination0:numeric-destination","operand:source0:packed-predicate-mask","operand:source1:persistent-source-true","operand:source2:persistent-source-false","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TSEL, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Predicate, SrcTrue, mask=PE_MASK","B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TSEL <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","A zero predicate bit selects SrcFalse and a one predicate bit selects SrcTrue. TSEL is a raw-carrier operation: it copies the chosen source carrier bits, preserves the concrete DataType, does not require TileNumericEncodingValid for selected payloads, and performs no conversion or numeric-status update."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TSEL, E3M2; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK; B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed binding order, B.IOR or B.IOS presence, missing or zero dimensions, ordinary numeric mask storage, undefined predicate or data elements, unsupported DataType, shape, type or layout mismatch, unequal masks, or insufficient destination capacity raises Fault_TileLegality or Fault_TileAllocation before architectural effects.","TSEL performs no conversion and therefore raises no floating invalid condition solely because a selected source encoding represents NaN.","CompleteBundleAtWithAcceptedApplicabilityRules supplies precise restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero numeric padding when B.DATR is present; omission selects Null."},"legality":["TSEL is selected only by VEC Mode 0 Function 26 and has no standalone opcode.","Exactly two ordered Local B.IOT bindings are required. The first supplies packed Predicate and SrcTrue without Last or a destination; the second supplies SrcFalse and one new terminating destination. B.IOR, B.IOS, and additional bindings are illegal.","The data DataType is exactly HiF8, E4M3, E5M2, E3M2, E2M3, E8M0, S8, U8, FP16, BF16, S16, U16, FP32, TF32, HF32, S32, or U32; every other type, including FP64, S64, U64, and packed-X2 types, rejects before effects.","SrcTrue, SrcFalse, and destination match physical shape, valid shape, row-major layout, and DataType; every valid element of both data sources is defined, and numeric encoding validity is not required for selected carrier payloads.","Predicate uses predicate-kind storage, has the same Row, Col, ValidRow, and ValidCol as the data Tiles, and defines every valid predicate bit. An ordinary numeric Tile is not a legal mask.","PadValueOrByteId is the only applicable B.DATR field. Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","Both B.IOT bindings use one PE_MASK. PE_MASK=0000 is a strict no-op before schema, source, allocation, or payload checks."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"source0","role":"packed one-bit Local predicate mask"},{"field":"source1","role":"persistent Local source selected by one"},{"field":"source2","role":"persistent Local source selected by zero"}],"ordering":["Complete schema, field, type, geometry, layout, definedness, predicate-kind, mask, and destination-capacity preflight precedes all source snapshots and allocation.","Predicate bits and both data payloads are snapshotted before the first destination write, so equal sources and source/destination aliases observe read-old values."],"standalone_opcode":false,"state_effects":["For logical element i, read bit i mod 8 of byte floor(i/8), selecting the exact SrcTrue encoding when one and SrcFalse encoding when zero.","Perform no rounding, saturation, canonicalization, arithmetic, or floating-status update.","Publish selected payload, padding definedness, and destination descriptor atomically. Rejection has no architectural effect and all three sources persist."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TSEL","mnemonic":"TSEL","summary":"Select exact element encodings from two Local Tiles under one packed predicate Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSEL-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSEL MUST consume predicate-kind storage with one low-first packed bit per
// logical element and MUST reject an ordinary numeric mask before effects.
// Both data sources and the destination MUST use one supported numeric type
// and matching geometry. Complete preflight and all source snapshots MUST
// precede exact selected-encoding and padding publication as one atomic result.
// NDF-END: PTO-TSEL-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSEL() => TileOperation
begin
    return TileOperation_TSEL;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TSEL(
    data_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSEL(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    source_false: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileSelect(
        destination,
        predicate,
        source_true,
        source_false);
end;

readonly func InstructionContractHandler_TSEL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelect;
end;

func InstructionContractExecute_TSEL(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    source_false: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSEL(
        destination,
        predicate,
        source_true,
        source_false);
    ExecuteTileSelect(
        destination,
        predicate,
        source_true,
        source_false);
end;
// DOC-END: operation
