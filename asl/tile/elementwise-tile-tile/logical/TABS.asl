// PTO-INSTRUCTION: {"assembly":["TABS <bundle operands>"],"block":["BSTART.VEC TABS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[13],"catalog_records":[{"arguments":[{"constant":"TileUnary_ABS"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileUnary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":15,"legality_handler":"TileOperandsLegal_ExecuteTileUnary","mode":0,"name":"TABS","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x00F","semantic_handler":"ExecuteTileUnary","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TABS, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TABS <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","Signed integers use modulo-width absolute value, including retaining the minimum signed bit pattern; unsigned integers are unchanged. Floating values clear only the sign bit, including zeros, infinities, and NaN payloads, without reporting invalid solely for TABS."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TABS, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-row-major layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.","This operation introduces no memory fault and reports no floating invalid condition solely from its value transform."],"field_contracts":{},"field_zero_meanings":{},"legality":["TABS is BSTART.VEC Mode 0 Function 15 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.","The selected DataType is exactly FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.","Source and destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; the source valid region is fully defined.","Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","Floating source encodings invalid for the selected DataType reject before allocation or destination effects; PE_MASK zero is a strict no-op.","The selected DataType is the operation interpretation and the newly allocated destination backing DataType. Each ordinary source backing DataType may differ only when it is a non-packed type with the same element width; numeric source encodings are validated under the selected DataType, while raw logical and shift operations consume carrier bits."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"absolute-value source"}],"ordering":["The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.","Source-to-destination aliasing therefore observes the complete pre-operation source payload."],"standalone_opcode":false,"state_effects":["For every valid coordinate, compute signed modulo-width absolute value, unsigned identity, or floating sign-bit clearing according to DataType.","Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"],"engine":"VEC","id":"PTO-TILE-TABS","mnemonic":"TABS","summary":"Typed elementwise absolute value over one Local Tile source.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TABS-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TABS MUST select VEC Mode 0 Function 15 and MUST compute typed absolute
// value over one ordered Local source. Element-width integer behavior,
// floating sign clearing, supported types, closed unary schema, PadValue,
// complete preflight, source snapshot, and atomic destination publication
// MUST follow ADR-0080 and NDF clause PTO-TABS-CONTRACT-001. Rejection MUST
// precede all architectural effects.
// The selected DataType MUST be the operation interpretation and new destination
// backing type. An ordinary source backing type MAY differ only for a same-width
// non-packed carrier; numeric validation MUST use the selected DataType.
// NDF-END: PTO-TABS-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TABS() => TileOperation
begin
    return TileOperation_TABS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TABS(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TABS(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_ABS,
        destination,
        source);
end;

pure func InstructionContractValue_TABS(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_ABS,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TABS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TABS(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_ABS, destination, source);
end;
// DOC-END: operation
