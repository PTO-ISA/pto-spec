// PTO-INSTRUCTION: {"assembly":["TFMA <bundle operands>"],"block":["BSTART.VEC TFMA, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK","B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[24],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"TFMA","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":28,"legality_handler":"TileOperandsLegal_TFMA","mode":0,"name":"TFMA","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"multiplicand-left"},{"field":"source1","role":"multiplicand-right"},{"field":"source2","role":"addend"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01C","semantic_handler":"TFMA","state_effects":["operand:destination0:destination","operand:source0:multiplicand-left","operand:source1:multiplicand-right","operand:source2:addend"]}],"classification":["elementwise-tile-tile","arithmetic"],"contract":{"block_composition":["BSTART.VEC TFMA, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcLeft, SrcRight, mask=PE_MASK","B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TFMA <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol; omitted LB1 defaults ValidRow to one and omitted LB2 defaults Col to ValidCol. Physical rows derive exactly from TSize, Col, and DataType.","Omitted B.DATR selects PadValue=Null; explicit 00, 01, 10, and 11 select Zero, Max, Min, and Null.","TFMA uses the selected numeric profile's fixed/default arithmetic rounding. It does not consume encoded RMode, Sat, or Canonicalize fields."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TFMA, FP32; B.DIM LB0=ValidCol; B.IOT SrcLeft, SrcRight, mask=PE_MASK; B.IOT SrcAddend, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed or surplus bindings, B.IOR or B.IOS, unequal masks, missing or invalid dimensions, unsupported DataType, non-row-major layout, undefined source elements, mismatched descriptors, or invalid floating encodings raise Fault_TileLegality before effects.","An unrepresentable destination shape, unavailable renamed destination, insufficient per-PE TSize, or exhausted architectural Tile capacity raises Fault_TileAllocation before allocation.","A signaling NaN, zero multiplied by infinity, infinity multiplied by zero, or an infinite product added to an opposite-signed infinity produces a quiet NaN and records floating invalid without a synchronous trap."],"field_contracts":{},"field_zero_meanings":{},"legality":["TFMA is selected by the TEPL encoding carrier Mode 0 Function 28, canonically assembled with BSTART.VEC, and has no standalone opcode.","Exactly two ordered Local B.IOT bindings are required: the first supplies two multiplicands without a destination or last marker; the second supplies the addend and one new destination and terminates the sequence.","DataType is exactly one of FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, or U8.","All three sources and the destination match physical shape, valid shape, row-major layout, DataType, and PE_MASK; every valid source element is defined.","Only B.DATR PadValueOrByteId is applicable. Explicit nondefault CMode, Sat, Canonicalize, secondary DataType, RMode, or Layout is illegal.","B.IOR and B.IOS are illegal. All participating B.IOT masks are equal; PE_MASK zero is a strict no-op before source reads, allocation, arithmetic, flags, padding, or descriptor effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new renamed Local destination"},{"field":"source0","role":"left multiplicand Local source"},{"field":"source1","role":"right multiplicand Local source"},{"field":"source2","role":"fused addend Local source"}],"ordering":["Complete schema, dimension, DataType, layout, source-definedness, source-encoding, PE_MASK, destination-name, and capacity preflight precedes all three source snapshots.","Duplicate sources and any source-to-destination alias observe complete pre-operation source payloads. Sources persist after both successful and rejected blocks.","The complete result payload, selected padding definedness, sticky numeric flags, and renamed destination descriptor publish as one architectural operation; rejection has no architectural effect."],"standalone_opcode":false,"state_effects":["For floating DataTypes, each valid destination element is one fused left multiplied by right plus addend operation with no rounded intermediate product and one final profile rounding.","For signed and unsigned integer DataTypes, each valid destination element is left multiplied by right plus addend modulo the element width; carrier bits above that width are zero.","The selected PadValue defines or leaves undefined the physical destination region outside ValidRow by ValidCol without changing any source descriptor or source payload."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT"],"engine":"VEC","id":"PTO-TILE-TFMA","mnemonic":"TFMA","summary":"Fused typed elementwise multiply-add over three Local Tile sources.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TFMA-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TFMA MUST select VEC Mode 0 Function 28 and MUST execute one same-type fused
// elementwise left multiplied by right plus addend operation. Supported types,
// the closed two-B.IOT schema, PadValue, exceptional floating cases, complete
// preflight, three-source snapshot, and atomic publication MUST follow PRD-081.
// Rejection MUST precede every architectural effect.
// NDF-END: PTO-TFMA-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TFMA() => TileOperation
begin
    return TileOperation_TFMA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TFMA(
    data_type: TileDataType) => boolean
begin
    return TileFusedMultiplyAddDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex) => boolean
begin
    return TileOperandsLegal_TFMA(
        destination,
        source_left,
        source_right,
        addend);
end;

func InstructionContractValue_TFMA(
    data_type: TileDataType,
    left: Word,
    right: Word,
    addend: Word) => (Word, bits(5))
begin
    return TileFixedFusedMultiplyAddValue(
        data_type,
        left,
        right,
        addend);
end;

readonly func InstructionContractHandler_TFMA() => TileSemanticHandler
begin
    return TileHandler_TFMA;
end;

func InstructionContractExecute_TFMA(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    addend: TileIndex)
begin
    TFMA(
        destination,
        source_left,
        source_right,
        addend);
end;
// DOC-END: operation
