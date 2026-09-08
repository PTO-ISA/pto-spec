// PTO-INSTRUCTION: {"assembly":["TSELS <bundle operands>"],"block":["BSTART.VEC TSELS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT PredicateCell, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize> OR GPR predicate form without PredicateCell","B.IOR predicate-GPR source and optional scalar-false source","BSTOP"],"catalog_indices":[38],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileSelectScalar","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":26,"legality_handler":"TileOperandsLegal_ExecuteTileSelectScalar","mode":1,"name":"TSELS","operands":[{"field":"destination0","role":"new Local numeric destination"},{"field":"source0","role":"legacy Predicate, CUBE PredicateCell, or GPR mask role"},{"field":"source1","role":"persistent Local source selected by one"},{"field":"scalar0","role":"per-participating-PE scalar selected by zero"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x03A","semantic_handler":"ExecuteTileSelectScalar","state_effects":["operand:destination0:new-local-numeric-destination","operand:source0:variant-predicate-mask-carrier","operand:source1:persistent-local-source-true","operand:scalar0:private-gpr-scalar-false","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["tile-scalar-and-immediate","logical"],"contract":{"block_composition":["BSTART.VEC TSELS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT PredicateCell, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize> OR GPR predicate form without PredicateCell","B.IOR predicate-GPR source and optional scalar-false source","BSTOP"],"canonical_assembly":["TSELS <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol.","Omitted B.IOR supplies the selected operation DataType all-zero false scalar; explicit all-zero is distinct but supplies the same value. TSELS is a raw-carrier operation: predicate-one copies SrcTrue backing bits, predicate-zero copies the scalar's normalized low physical bits, publishes the destination with the operation DataType, does not require TileNumericEncodingValid for selected source or scalar payloads, and performs no conversion or numeric-status update.","Omitted B.DATR selects PadValue=Null. Explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TSELS, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT Predicate, SrcTrue, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR ScalarFalseGPR, zero, zero, ->zero (optional); BSTOP"],"exceptions":["Malformed or mixed carrier schemas, unsupported type, wrong operation-type PredicateCell basis, noncanonical predicate bytes, undefined source data, shape/layout mismatch, insufficient destination capacity, or allocation failure rejects before effects.","TSELS copies raw carrier encodings and does not itself raise floating invalid for a selected NaN payload."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when present; omission selects Null.","B.IOR.RegSrc0":"Architectural zero register."},"legality":["TSELS selects TEPL Mode 1 Function 26 and executes on VEC. PE_MASK=0000 is a strict no-op before GPR, predicate, source, allocation, or payload checks.","Legacy RowMajor form uses one terminating B.IOT with packed Predicate, SrcTrue, and one new destination; one B.IOR source supplies scalar-false or omission selects the operation-type zero, and the source backing remains independently width-compatible.","CUBE_M16/M32 PredicateCell form uses one terminating B.IOT with a PredicateCell whose basis equals the operation DataType, SrcTrue, and one new CUBE destination plus an optional scalar-false B.IOR source; omission selects the operation-type zero. The true-source backing remains independently width-compatible.","CUBE_M16/M32 GPR form uses one B.IOT with SrcTrue and one new CUBE destination. One source-only B.IOR carries the complete predicate mask followed by the independent scalar-false source: two sources for one-word masks and three for U8's two-word mask. The operation type is a 32-bit or 16-bit type from the closed CUBE domain, plus U8; the true-source backing remains independently width-compatible.","Legacy, PredicateCell, and GPR forms are complete and mutually exclusive. PadValueOrByteId is the only applicable B.DATR field."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new RowMajor or CUBE numeric destination"},{"field":"source0","role":"legacy packed Predicate, CUBE PredicateCell, or GPR mask role"},{"field":"source1","role":"persistent source selected by predicate one"},{"field":"scalar0","role":"independent scalar selected by predicate zero"}],"ordering":["Complete schema, dimensions, attributes, predicate-kind, source-definedness, scalar encoding, mask, capacity, and allocation preflight precedes snapshots.","Predicate bits, true-source payload, and scalar are snapshotted before destination publication."],"standalone_opcode":false,"state_effects":["Predicate bit one copies the exact SrcTrue backing encoding and bit zero copies the normalized operation-type scalar encoding.","Selection performs no rounding, saturation, canonicalization, or numeric-status update.","Selected payload, padding definedness, and destination descriptor publish atomically; rejection has no architectural effect."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"VEC","id":"PTO-TILE-TSELS","mnemonic":"TSELS","summary":"Select each result encoding from a Local Tile or scalar under one legacy Predicate, CUBE PredicateCell, or GPR mask carrier.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSELS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSELS MUST consume exactly one mutually exclusive mask carrier, one Local
// true source, and the selected false scalar. The selected operation type MUST
// govern mask interpretation and destination DataType; the true-source backing
// DataType remains distinct, non-four-bit, same-width, and compatible. Omitted
// B.IOR supplies the operation-type all-zero scalar; explicit scalar encoding
// is normalized under that type but selected bits are copied raw. PredicateCell
// basis and CUBE GPR geometry MUST derive from the operation type, and CUBE
// physical geometry MUST remain invariant for allowed same-width pairs.
// Predicate one MUST copy source encoding and zero MUST copy scalar encoding.
// Complete preflight and snapshots MUST precede atomic publication.
// NDF-END: PTO-TSELS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSELS() => TileOperation
begin
    return TileOperation_TSELS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TSELS(
    data_type: TileDataType) => boolean
begin
    return TileSelectDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TSELS(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    scalar_false: Word) => boolean
begin
    return TileOperandsLegal_ExecuteTileSelectScalar(
        destination,
        predicate,
        source_true,
        scalar_false);
end;

readonly func InstructionContractHandler_TSELS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelectScalar;
end;

func InstructionContractExecute_TSELS(
    destination: TileIndex,
    predicate: TileIndex,
    source_true: TileIndex,
    scalar_false: Word)
begin
    assert InstructionContractOperandsLegal_TSELS(
        destination,
        predicate,
        source_true,
        scalar_false);
    ExecuteTileSelectScalar(
        destination,
        predicate,
        source_true,
        scalar_false);
end;
// DOC-END: operation
