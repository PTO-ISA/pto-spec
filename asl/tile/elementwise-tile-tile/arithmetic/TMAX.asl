// PTO-INSTRUCTION: {"assembly":["TMAX <bundle operands>"],"block":["BSTART.VEC TMAX, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[10],"catalog_records":[{"arguments":[{"constant":"TileBinary_MAX"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileBinary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":11,"legality_handler":"TileOperandsLegal_ExecuteTileBinary","mode":0,"name":"TMAX","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source-left"},{"field":"source1","role":"source-right"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x00B","semantic_handler":"ExecuteTileBinary","state_effects":["operand:destination0:destination","operand:source0:source-left","operand:source1:source-right"]}],"classification":["elementwise-tile-tile","arithmetic"],"contract":{"block_composition":["BSTART.VEC TMAX, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TMAX <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","For floating TMAX, one NaN selects the numeric operand, two NaNs select canonical NaN, signaling NaN reports invalid, and mixed signed zeros select positive zero."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TMAX, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed bindings, missing or zero dimensions, undefined or mismatched sources, unsupported DataType, non-row-major layout, invalid source encoding, or invalid destination capacity raises Fault_TileLegality before effects.","A signaling NaN reports the selected numeric profile invalid condition without changing the deterministic selected result."],"field_contracts":{},"field_zero_meanings":{},"legality":["TMAX is BSTART.VEC Mode 0 Function 11 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies two ordered Local sources and one new Local destination; B.IOR and B.IOS are illegal.","DataType is one of S32, U32, FP32, S16, U16, FP16, BF16, S8, or U8.","Sources are fully defined and all three Tiles match physical shape, valid shape, row-major layout, DataType, and PE_MASK.","Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","Floating source encodings invalid for the selected operation reject before allocation or destination effects; PE_MASK zero is a strict no-op."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"left comparison source"},{"field":"source1","role":"right comparison source"}],"ordering":["Both source payloads are snapshotted after complete legality and encoding preflight and before destination writes.","Source aliasing and source-to-destination aliasing therefore observe pre-operation values."],"standalone_opcode":false,"state_effects":["Select the typed elementwise maximum for every valid coordinate.","Signed integers use signed ordering, unsigned integers use unsigned ordering, and supported floating carriers use deterministic NaN and signed-zero rules.","Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"],"engine":"VEC","id":"PTO-TILE-TMAX","mnemonic":"TMAX","summary":"Maximum corresponding Local Tile elements under typed integer and floating ordering.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMAX-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TMAX MUST select VEC Mode 0 Function 11 and MUST compute a typed maximum
// over two ordered Local sources. Integer ordering MUST follow signedness.
// Floating NaN, signaling-NaN status, signed-zero ties, source-encoding
// legality, closed binary schema, PadValue, complete preflight, source
// snapshot, and atomic destination publication MUST follow PRD-067.
// Rejection MUST precede all architectural effects.
// NDF-END: PTO-TMAX-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMAX() => TileOperation
begin
    return TileOperation_TMAX;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TMAX(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TMAX(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileBinary(
        TileBinary_MAX,
        destination,
        source_left,
        source_right);
end;

pure func InstructionContractFloatingValue_TMAX(
    data_type: TileDataType,
    source_left: Word,
    source_right: Word) => (Word, boolean)
begin
    assert InstructionContractDataTypeLegal_TMAX(data_type);
    assert TileDataTypeIsFloating(data_type);
    return TileFloatingMinMaxValue(
        TileBinary_MAX,
        data_type,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TMAX() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;

func InstructionContractExecute_TMAX(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    ExecuteTileBinary(
        TileBinary_MAX,
        destination,
        source_left,
        source_right);
end;
// DOC-END: operation
