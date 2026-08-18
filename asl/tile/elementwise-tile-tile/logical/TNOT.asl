// PTO-INSTRUCTION: {"assembly":["TNOT <bundle operands>"],"block":["BSTART.VEC TNOT, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[14],"catalog_records":[{"arguments":[{"constant":"TileUnary_NOT"},{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileUnary","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":16,"legality_handler":"TileOperandsLegal_ExecuteTileUnary","mode":0,"name":"TNOT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x010","semantic_handler":"ExecuteTileUnary","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["elementwise-tile-tile","logical"],"contract":{"block_composition":["BSTART.VEC TNOT, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TNOT <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","TNOT complements exactly the selected 8-, 16-, 32-, or 64-bit element width and zero-extends the result to the Tile payload carrier."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TNOT, U64; B.DIM LB0=ValidCol; B.IOT Src, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed bindings, missing or zero dimensions, undefined or mismatched source state, unsupported DataType, non-row-major layout, or invalid floating source encoding raises Fault_TileLegality before effects; an unrepresentable destination shape or insufficient TSize capacity raises Fault_TileAllocation before allocation.","This operation introduces no memory fault and reports no floating invalid condition solely from its value transform."],"field_contracts":{},"field_zero_meanings":{},"legality":["TNOT is BSTART.VEC Mode 0 Function 16 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies one Local source and one new Local destination; B.IOR and B.IOS are illegal.","DataType is one of S64, S32, S16, S8, U64, U32, U16, or U8.","Source and destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; the source valid region is fully defined.","Only B.DATR PadValueOrByteId is applicable; nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","PE_MASK zero is a strict no-op before dimensions, source access, schema checks, or destination allocation."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local destination"},{"field":"source0","role":"bitwise source"}],"ordering":["The source payload is snapshotted after complete schema, dimension, DataType, layout, definedness, encoding, mask, and destination-capacity preflight and before destination writes.","Source-to-destination aliasing therefore observes the complete pre-operation source payload."],"standalone_opcode":false,"state_effects":["For every valid coordinate, complement exactly the selected integer element width and clear upper carrier bits.","Publish the complete valid result and selected physical padding atomically; rejection has no architectural effect."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"],"engine":"VEC","id":"PTO-TILE-TNOT","mnemonic":"TNOT","summary":"Element-width bitwise complement over one Local integer Tile source.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TNOT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TNOT MUST select VEC Mode 0 Function 16 and MUST complement only the
// selected 8, 16, 32, or 64-bit integer element width. Supported types,
// closed unary schema, PadValue, complete preflight, source snapshot, and
// atomic destination publication MUST follow PRD-071. Rejection MUST precede
// all architectural effects.
// NDF-END: PTO-TNOT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TNOT() => TileOperation
begin
    return TileOperation_TNOT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TNOT(
    data_type: TileDataType) => boolean
begin
    return TileVecScalarIntegerDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TNOT(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileUnary(
        TileUnary_NOT,
        destination,
        source);
end;

pure func InstructionContractValue_TNOT(
    data_type: TileDataType,
    source: Word) => Word
begin
    let (result, -) = TileFixedUnaryValue(
        TileUnary_NOT,
        data_type,
        source);
    return result;
end;

readonly func InstructionContractHandler_TNOT() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;

func InstructionContractExecute_TNOT(
    destination: TileIndex,
    source: TileIndex)
begin
    ExecuteTileUnary(TileUnary_NOT, destination, source);
end;
// DOC-END: operation
