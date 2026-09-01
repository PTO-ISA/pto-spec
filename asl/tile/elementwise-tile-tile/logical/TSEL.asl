// PTO-INSTRUCTION: {"assembly":["TSEL <bundle operands>"],"block":["BSTART.VEC TSEL, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT PredicateCell, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize> OR GPR predicate form without PredicateCell","B.IOT SrcFalse, <last>, ->DstTile<TSize> (CellReg form only)","B.IOR predicate-GPR source (GPR form only)","BSTOP"],"catalog_indices":[22],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileSelect","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":26,"legality_handler":"TileOperandsLegal_ExecuteTileSelect","mode":0,"name":"TSEL","operands":[{"field":"destination0","role":"numeric destination"},{"field":"source0","role":"legacy Predicate, CUBE PredicateCell, or first GPR-mask role"},{"field":"source1","role":"source-true"},{"field":"source2","role":"source-false"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01A","semantic_handler":"ExecuteTileSelect","state_effects":["operand:destination0:numeric-destination","operand:source0:variant-predicate-mask-carrier","operand:source1:persistent-source-true","operand:source2:persistent-source-false","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TSEL, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT PredicateCell, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize> OR GPR predicate form without PredicateCell","B.IOT SrcFalse, <last>, ->DstTile<TSize> (CellReg form only)","B.IOR predicate-GPR source (GPR form only)","BSTOP"],"canonical_assembly":["TSEL <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","A zero predicate bit selects SrcFalse and a one predicate bit selects SrcTrue. TSEL is a raw-carrier operation: it copies the chosen source carrier bits, preserves the concrete DataType, does not require TileNumericEncodingValid for selected payloads, and performs no conversion or numeric-status update."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TSEL, E3M2; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK; B.IOT SrcFalse, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed or mixed carrier schemas, missing dimensions, unsupported DataType, wrong PredicateCell basis, noncanonical predicate bytes, undefined source data, shape/layout mismatch, insufficient destination capacity, or allocation failure rejects before effects.","TSEL is a raw-carrier select and does not raise floating invalid solely because a selected source payload encodes NaN."],"field_contracts":{},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero numeric padding when B.DATR is present; omission selects Null."},"legality":["TSEL selects VEC Mode 0 Function 26. PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks.","Legacy RowMajor form uses two ordered B.IOT records: packed Predicate plus SrcTrue, then SrcFalse plus one new destination; B.IOR is absent.","CUBE_M16/M32 PredicateCell form uses the same two-record Tile structure with a canonical PredicateCell whose basis DataType, valid shape, and layout match the numeric sources. The data type is exactly one of FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S32, S16, S8, U32, U16, or U8; B.IOR is absent.","CUBE_M16/M32 GPR form uses one B.IOT with SrcTrue, SrcFalse, and one new CUBE destination plus one source-only B.IOR carrying the complete mask. The type is 32-bit or 16-bit types from the closed CUBE domain, plus U8; U8 consumes two mask GPRs and other accepted types consume one.","Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. PadValueOrByteId is the only applicable B.DATR field."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new RowMajor or CUBE numeric destination"},{"field":"source0","role":"legacy packed Predicate, CUBE PredicateCell, or first GPR-mask role"},{"field":"source1","role":"persistent source selected by predicate one"},{"field":"source2","role":"persistent source selected by predicate zero"}],"ordering":["Complete schema, field, type, geometry, layout, definedness, predicate-kind, mask, and destination-capacity preflight precedes all source snapshots and allocation.","Predicate bits and both data payloads are snapshotted before the first destination write, so equal sources and source/destination aliases observe read-old values."],"standalone_opcode":false,"state_effects":["For each logical element, read the selected carrier predicate and copy the exact SrcTrue encoding when one or SrcFalse encoding when zero.","Perform no rounding, saturation, canonicalization, arithmetic, or floating-status update.","Publish selected payload, padding definedness, and destination descriptor atomically. Rejection has no architectural effect and all three sources persist."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TSEL","mnemonic":"TSEL","summary":"Select exact element encodings under one legacy Predicate, CUBE PredicateCell, or GPR mask carrier.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSEL-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSEL MUST consume exactly one mutually exclusive mask carrier. The legacy
// RowMajor form MUST consume one low-index-first packed Predicate bit per
// logical element. A CUBE form MUST consume either canonical basis-matched
// PredicateCell bytes or a complete one- or two-word GPR mask. Both data
// sources and the destination MUST use one supported numeric type and matching
// geometry. Complete preflight and all source snapshots MUST precede atomic
// selected-encoding, padding, and destination-descriptor publication.
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
