// PTO-INSTRUCTION: {"assembly":["TCVT <bundle operands>"],"block":["BSTART.VEC TCVT, SrcDataType","B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[23],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"numeric_control"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Sat","Canonicalize","DataType","RMode","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"TCVT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":27,"legality_handler":"TileOperandsLegal_TCVT","mode":0,"name":"TCVT","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"},{"field":"numeric_control","role":"rounding-and-saturation"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01B","semantic_handler":"TCVT","state_effects":["operand:destination0:typed-layout-transformed-destination","operand:source0:persistent-source","operand:numeric_control:rounding-and-saturation","runtime:CurrentBundlePadValue:physical-padding"]}],"classification":["elementwise-tile-tile","format-conversion"],"contract":{"block_composition":["BSTART.VEC TCVT, SrcDataType","B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TCVT <bundle operands>"],"defaults":["The BSTART DataType is SrcDataType. Omitted B.DATR or DTYPE_NONE inherits SrcDataType as DstDataType; an explicitly encoded DataType zero selects FP64.","LB0 is required and supplies ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol. Every present dimension must be nonzero.","RMode zero selects RTZ for floating-to-integer conversion and RNE for every other conversion that requires rounding. Sat zero disables saturation and Canonicalize zero selects an ordinary public source.","Omitted B.DATR selects Layout=NORM and PadValue=Null. Explicit PadValue codes 00, 01, 10, and 11 select Zero, Max, Min, and Null.","For an E8M0 destination, RMode rounds the base-two exponent. Exact powers of two are exact; Sat selects finite endpoint clamp versus 0xFF for finite range overflow or underflow."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TCVT, SrcDataType; B.DATR DstDataType, RMode, Sat, Canonicalize, Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed bindings, missing or zero dimensions, type, shape, capacity, layout, canonicalization, encoding, or definedness mismatch raises Fault_TileLegality before destination allocation or payload effects.","Reserved selector, DataType, or Layout encodings raise the corresponding instruction or Tile legality fault before effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation.","For E8M0, zero, negative values, and NaNs produce 0xFF with NV. Positive infinity follows the overflow rule. Finite values below 2^-127 or above 2^127 produce 0xFF when Sat=0 or clamp to 0x00/0xFE when Sat=1, with UF/OF plus NX."],"field_contracts":{"BSTART.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"},"B.DATR.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"B.DATR.DataType":"FP64; DTYPE_NONE, not zero, requests inheritance.","B.DATR.Layout":"NORM.","B.DATR.RMode":"TCVT operation default.","B.DATR.Sat":"Saturation disabled.","B.DATR.Canonicalize":"Ordinary public source.","B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null."},"legality":["TCVT is selected only by VEC Mode 0 Function 27 and has no standalone opcode.","Exactly one terminating Local B.IOT supplies one source and one newly allocated destination. B.IOR, B.IOS, a second source, and a second binding are illegal.","For ordinary layouts, source and destination have equal Row, Col, ValidRow, and ValidCol. For a CUBE_M16 or CUBE_M32 source, the destination preserves the same CUBE layout and ValidRow/ValidCol, while Row, Col, CELL count, capacity, and packing independently match the destination DataType.","Every assigned Tile DataType is legal. Reserved five-bit DataType codes reject before effects; HiF4X2 is TCVT-only.","Every assigned Layout code has executable indexing. The source descriptor matches the transform source layout and the destination descriptor matches its target layout; CUBE_M16 and CUBE_M32 conversions retain the source layout.","A private CUBE source requires Canonicalize=1 and Layout=NORM. A CUBE_M16 or CUBE_M32 matrix source requires Canonicalize=0 and Layout=NORM; its destination remains a Matrix CUBE representation. An ordinary source requires Canonicalize=0.","The source valid region is fully defined and contains valid encodings. PE_MASK=0000 is a strict no-op before schema, descriptor, allocation, or payload checks.","Under the named hardware profile, an E8M0 destination accepts exactly FP16, BF16, or FP32 sources. Every other source-to-E8M0 pair rejects before destination allocation.","The BSTART DataType is the source operation interpretation, not necessarily the ordinary source backing DataType. An ordinary non-packed source may differ only by same-width backing type; Matrix/CUBE sources retain exact backing/source-operation type equality. The destination backing type is the resolved B.DATR destination type."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new typed and laid-out Local destination"},{"field":"source0","role":"persistent Local source"},{"field":"numeric_control","role":"resolved rounding and saturation"}],"ordering":["Complete schema, type, logical geometry, layout, canonicalization, capacity, encoding, and definedness preflight precedes the source snapshot and destination allocation.","Converted payload, numeric status, padding definedness, public representation state, and destination descriptor publish atomically."],"standalone_opcode":false,"state_effects":["Snapshot the persistent source, convert every valid logical element under the resolved rounding and saturation controls, and write the corresponding logical coordinate in the destination layout.","Define or undefine every physical padding coordinate according to PadValue and publish the destination; ordinary conversions use the public representation, while CUBE_M16 and CUBE_M32 conversions retain the Matrix CUBE representation.","The source may alias the destination; execution observes the complete pre-execution source snapshot.","For a supported E8M0 conversion, map the rounded base-two exponent to code exponent+127 and accumulate exact NV/UF/OF/NX status before atomic publication."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING","PTO-ARCH-PROFILE-E8M0-CONVERSION"],"engine":"VEC","id":"PTO-TILE-TCVT","mnemonic":"TCVT","summary":"Convert every valid source element to a separately typed and laid-out Local destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCVT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCVT MUST accept every assigned Tile DataType, MUST distinguish omitted or
// DTYPE_NONE destination type from encoded FP64, MUST execute every assigned
// Layout transformation, and MUST reject an incompatible private/public
// representation before destination allocation or payload effects.
// For CUBE_M16/M32 matrix sources with Layout=NORM and Canonicalize=0,
// TCVT MUST preserve the CUBE layout and valid shape while deriving the
// destination physical shape, CELL count, and minimum TSize from the
// destination DataType. LB0/LB1 MUST match the source valid shape and LB2 MUST
// be omitted; violations MUST raise Fault_TileLegality before allocation.
// After that preflight, an insufficient destination TSize MUST raise
// Fault_TileAllocation without destination effects. Under the
// named hardware profile an E8M0 destination MUST accept only FP16, BF16, or
// FP32 sources and MUST apply PTO-TCVT-E8M0-PROFILE-001 exactly.
// For an ordinary non-packed source, the BSTART source operation type MAY differ
// from the backing type only at the same element width. Matrix/CUBE sources MUST
// retain exact backing/source-operation type equality, and the destination backing
// type MUST equal the resolved destination operation type.
// NDF-END: PTO-TCVT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCVT() => TileOperation
begin
    return TileOperation_TCVT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TCVT(
    data_type: TileDataType) => boolean
begin
    // TileDataType has exactly the twenty-five assigned architectural values.
    // Reserved five-bit encodings never enter this semantic type.
    return TRUE;
end;

pure func InstructionContractDestinationDataType_TCVT(
    source_type: TileDataType,
    data_type_field_present: boolean,
    data_type_code: bits(5)) => TileDataType
begin
    if data_type_field_present && BundleDataTypeConcrete(data_type_code) then
        return BundleTileDataType(data_type_code);
    end;
    return source_type;
end;

pure func InstructionContractDefaultRounding_TCVT(
    source_type: TileDataType,
    destination_type: TileDataType) => NumericRoundingMode
begin
    if TileDataTypeIsFloating(source_type) &&
       TileDataTypeIsInteger(destination_type) then
        return NumericRound_RTZ;
    end;
    return NumericRound_RNE;
end;

func InstructionContractExecute_TCVT(
    destination: TileIndex,
    source: TileIndex,
    control: NumericExecutionControl)
begin
    assert TileOperandsLegal_TCVT(destination, source, control);
    TCVT(destination, source, control);
end;

readonly func InstructionContractHandler_TCVT() => TileSemanticHandler
begin
    return TileHandler_TCVT;
end;
// DOC-END: operation
