// PTO-INSTRUCTION: {"assembly":["TQUANT <bundle operands>"],"block":["BSTART.SFU TQUANT, FP32","B.DATR S8|U8, RMode, Sat","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1)","B.DIM LB2=Col (optional, default ValidCol)","B.IOR MultiplierFP32, ZeroPoint (optional; omission selects 1.0 and 0)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[76],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"scalar1"},{"operand":"numeric_control"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Sat","DataType","RMode"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TQUANT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":10,"legality_handler":"TileOperandsLegal_TQUANT","mode":3,"name":"TQUANT","operands":[{"field":"destination0","role":"new S8 or U8 destination"},{"field":"source0","role":"persistent FP32 source"},{"field":"scalar0","role":"positive finite FP32 multiplier"},{"field":"scalar1","role":"destination-typed integer zero point"},{"field":"numeric_control","role":"rounding and saturation"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06A","semantic_handler":"TQUANT","state_effects":["operand:destination0:new-s8-or-u8-destination","operand:source0:persistent-fp32-source","operand:scalar0:positive-finite-fp32-multiplier","operand:scalar1:destination-typed-zero-point","operand:numeric_control:rounding-and-saturation","runtime:TilePad_Null:physical-padding"]}],"classification":["irregular-and-complex","format-conversion"],"contract":{"block_composition":["BSTART.SFU TQUANT, FP32","B.DATR S8|U8, RMode, Sat","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1)","B.DIM LB2=Col (optional, default ValidCol)","B.IOR MultiplierFP32, ZeroPoint (optional; omission selects 1.0 and 0)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TQUANT <bundle operands>"],"defaults":["BSTART DataType is exactly FP32 and B.DATR is mandatory with destination DataType S8 or U8.","LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one and omitted LB2 selects Col equal to ValidCol.","Omitted B.IOR selects the raw FP32 multiplier encoding 0x3f800000 and zero point zero. A present all-zero B.IOR selects multiplier zero and is illegal.","RMode zero selects RNE. Sat zero selects modulo destination-width conversion; Sat one clamps to the destination range.","Canonicalize, Layout, CMode, and PadValue are inapplicable and must be zero. Physical padding is always Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TQUANT, FP32; B.DATR S8, RNE, Sat=1; B.DIM LB0=16; B.IOT T1, mask=1111, <last>, ->T0<1>; BSTOP"],"exceptions":["Missing or surplus bindings, B.IOS, absent or invalid B.DATR, unsupported types, non-row-major layout, malformed dimensions, undefined or invalid source elements, non-finite, negative, or zero multiplier, or an out-of-range zero point raises Fault_TileLegality before allocation or payload effects.","An unrepresentable destination shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before allocation.","PE_MASK zero is a strict no-op before schema, GPR, descriptor, allocation, numeric-status, padding, or payload effects."],"field_contracts":{"BSTART.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"},"B.DATR.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"BSTART.DataType":"FP64 and therefore illegal for TQUANT; source type must encode FP32.","B.DATR.DataType":"FP64 and therefore illegal for TQUANT; destination must encode S8 or U8.","B.DATR.RMode":"RNE.","B.DATR.Sat":"Modulo destination-width conversion.","B.DATR.Canonicalize":"Must remain zero.","B.DATR.Layout":"NORM; every source and destination is row-major.","B.DATR.PadValueOrByteId":"Must remain zero; TQUANT physical padding is Null.","B.IOR":"Omission selects multiplier 1.0 and zero point 0; an encoded zero selector is a real GPR0 read."},"legality":["TQUANT is selected by the TEPL encoding carrier Mode 3 Function 10, canonically assembled with BSTART.SFU, and has no standalone opcode.","Exactly one terminating Local B.IOT supplies one FP32 source and one new S8 or U8 destination. B.IOS, a second B.IOT, a second source, and a second destination are illegal.","B.DATR is mandatory and permits only DataType, RMode, and Sat. DataType is exactly S8 or U8.","The source valid region and physical Col match LB1, LB0, and LB2 respectively. Source and destination are row-major and their capacities independently match their DataTypes.","A present B.IOR consumes RegSrc0 as a positive, finite, nonzero raw FP32 multiplier and RegSrc1 as a canonically encoded zero point in the destination integer type. RegSrc2 and RegDst are zero.","The complete FP32 source valid region is defined and contains valid encodings. All participating masks are equal; PE_MASK zero is a strict no-op."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new S8 or U8 destination"},{"field":"source0","role":"persistent FP32 source"},{"field":"scalar0","role":"positive finite FP32 multiplier"},{"field":"scalar1","role":"destination-typed integer zero point"},{"field":"numeric_control","role":"rounding and saturation"}],"ordering":["Complete schema, fields, type, shape, capacity, source-definedness, source-encoding, multiplier, zero-point, mask, destination-name, and allocation preflight precedes the source snapshot.","The source persists. The result payload, sticky numeric flags, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For every valid element x, compute x multiplied by MultiplierFP32 plus ZeroPoint, then round using RMode.","Sat one clamps the rounded value to S8 or U8 range. Sat zero converts modulo the destination width.","Every physical destination coordinate outside ValidRow by ValidCol is undefined Null padding."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-QUANTIZATION-SCHEMA","PTO-TILE-MODEL-NUMERIC-FORMATS"],"engine":"SFU","id":"PTO-TILE-TQUANT","mnemonic":"TQUANT","summary":"Affine-quantize a Local FP32 Tile into a new Local S8 or U8 Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TQUANT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TQUANT MUST select SFU Mode 3 Function 10. It MUST accept one persistent
// Local FP32 source and MUST publish one newly allocated Local S8 or U8
// destination. Each valid result MUST equal the rounded value of source times
// a positive finite FP32 multiplier plus a destination-typed zero point.
// Omitted B.IOR MUST select multiplier 1.0 and zero point zero. A present zero
// multiplier MUST be rejected before allocation or architectural effects.
// NDF-END: PTO-TQUANT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TQUANT() => TileOperation
begin
    return TileOperation_TQUANT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypesLegal_TQUANT(
    source_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return source_type == TileDataType_FP32 &&
           (destination_type == TileDataType_S8 ||
            destination_type == TileDataType_U8);
end;

pure func InstructionContractDefaultMultiplier_TQUANT() => Word
begin
    return Zeros{PTO_XLEN} + 0x3f800000;
end;

pure func InstructionContractDefaultZeroPoint_TQUANT() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractScaleLegal_TQUANT(scale: Word) => boolean
begin
    return TileQuantizationScaleLegal(scale);
end;

pure func InstructionContractZeroPointLegal_TQUANT(
    zero_point: Word,
    destination_type: TileDataType) => boolean
begin
    return TileQuantizationZeroPointLegal(
        zero_point,
        destination_type);
end;

readonly func InstructionContractOperandsLegal_TQUANT(
    destination: TileIndex,
    source: TileIndex,
    multiplier: Word,
    zero_point: Word,
    control: NumericExecutionControl) => boolean
begin
    return TileOperandsLegal_TQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
end;

readonly func InstructionContractHandler_TQUANT() => TileSemanticHandler
begin
    return TileHandler_TQUANT;
end;

func InstructionContractExecute_TQUANT(
    destination: TileIndex,
    source: TileIndex,
    multiplier: Word,
    zero_point: Word,
    control: NumericExecutionControl)
begin
    assert InstructionContractOperandsLegal_TQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
    TQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
end;
// DOC-END: operation
