// PTO-INSTRUCTION: {"assembly":["TDEQUANT <bundle operands>"],"block":["BSTART.SFU TDEQUANT, S8|U8","B.DATR FP32, RMode","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1)","B.DIM LB2=Col (optional, default ValidCol)","B.IOR MultiplierFP32, ZeroPoint (optional; omission selects 1.0 and 0)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[77],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"},{"operand":"scalar1"},{"operand":"numeric_control"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["DataType","RMode"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TDEQUANT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":11,"legality_handler":"TileOperandsLegal_TDEQUANT","mode":3,"name":"TDEQUANT","operands":[{"field":"destination0","role":"new FP32 destination"},{"field":"source0","role":"persistent S8 or U8 source"},{"field":"scalar0","role":"positive finite FP32 multiplier"},{"field":"scalar1","role":"source-typed integer zero point"},{"field":"numeric_control","role":"rounding"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06B","semantic_handler":"TDEQUANT","state_effects":["operand:destination0:new-fp32-destination","operand:source0:persistent-s8-or-u8-source","operand:scalar0:positive-finite-fp32-multiplier","operand:scalar1:source-typed-zero-point","operand:numeric_control:rounding","runtime:TilePad_Null:physical-padding"]}],"classification":["irregular-and-complex","format-conversion"],"contract":{"block_composition":["BSTART.SFU TDEQUANT, S8|U8","B.DATR FP32, RMode","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1)","B.DIM LB2=Col (optional, default ValidCol)","B.IOR MultiplierFP32, ZeroPoint (optional; omission selects 1.0 and 0)","B.IOT SrcTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TDEQUANT <bundle operands>"],"defaults":["BSTART DataType is exactly S8 or U8 and B.DATR is mandatory with destination DataType FP32.","LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one and omitted LB2 selects Col equal to ValidCol.","Omitted B.IOR selects the raw FP32 multiplier encoding 0x3f800000 and zero point zero. A present all-zero B.IOR selects multiplier zero and is illegal.","RMode zero selects RNE. Sat, Canonicalize, Layout, CMode, and PadValue are inapplicable and must be zero. Physical padding is always Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TDEQUANT, S8; B.DATR FP32, RNE; B.DIM LB0=16; B.IOT T1, mask=1111, <last>, ->T0<1>; BSTOP"],"exceptions":["Missing or surplus bindings, B.IOS, absent or invalid B.DATR, unsupported types, non-row-major layout, malformed dimensions, undefined or invalid source elements, non-finite, negative, or zero multiplier, or an out-of-range zero point raises Fault_TileLegality before allocation or payload effects.","An unrepresentable destination shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before allocation.","PE_MASK zero is a strict no-op before schema, GPR, descriptor, allocation, numeric-status, padding, or payload effects."],"field_contracts":{"BSTART.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"},"B.DATR.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"BSTART.DataType":"FP64 and therefore illegal for TDEQUANT; source must encode S8 or U8.","B.DATR.DataType":"FP64, the required TDEQUANT destination type.","B.DATR.RMode":"RNE.","B.DATR.Sat":"Must remain zero.","B.DATR.Canonicalize":"Must remain zero.","B.DATR.Layout":"NORM; every source and destination is row-major.","B.DATR.PadValueOrByteId":"Must remain zero; TDEQUANT physical padding is Null.","B.IOR":"Omission selects multiplier 1.0 and zero point 0; an encoded zero selector is a real GPR0 read."},"legality":["TDEQUANT is selected by the TEPL encoding carrier Mode 3 Function 11, canonically assembled with BSTART.SFU, and has no standalone opcode.","Exactly one terminating Local B.IOT supplies one S8 or U8 source and one new FP32 destination. B.IOS, a second B.IOT, a second source, and a second destination are illegal.","B.DATR is mandatory and permits only DataType and RMode. DataType is exactly FP32; Sat is zero.","The source valid region and physical Col match LB1, LB0, and LB2 respectively. Source and destination are row-major and their capacities independently match their DataTypes.","A present B.IOR consumes RegSrc0 as a positive, finite, nonzero raw FP32 multiplier and RegSrc1 as a canonically encoded zero point in the source integer type. RegSrc2 and RegDst are zero.","The complete integer source valid region is defined and contains valid encodings. All participating masks are equal; PE_MASK zero is a strict no-op."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new FP32 destination"},{"field":"source0","role":"persistent S8 or U8 source"},{"field":"scalar0","role":"positive finite FP32 multiplier"},{"field":"scalar1","role":"source-typed integer zero point"},{"field":"numeric_control","role":"rounding"}],"ordering":["Complete schema, fields, type, shape, capacity, source-definedness, source-encoding, multiplier, zero-point, mask, destination-name, and allocation preflight precedes the source snapshot.","The source persists. The result payload, sticky numeric flags, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For every valid integer element q, compute FP32(q minus ZeroPoint) multiplied by MultiplierFP32 and round once using RMode.","Every physical destination coordinate outside ValidRow by ValidCol is undefined Null padding."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-QUANTIZATION-SCHEMA","PTO-TILE-MODEL-NUMERIC-FORMATS"],"engine":"SFU","id":"PTO-TILE-TDEQUANT","mnemonic":"TDEQUANT","summary":"Affine-dequantize a Local S8 or U8 Tile into a new Local FP32 Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TDEQUANT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TDEQUANT MUST select SFU Mode 3 Function 11. It MUST accept one persistent
// Local S8 or U8 source and MUST publish one newly allocated Local FP32
// destination. Each valid result MUST equal source minus the source-typed zero
// point, multiplied by a positive finite FP32 multiplier, with one FP32
// rounding. Omitted B.IOR MUST select multiplier 1.0 and zero point zero.
// A present zero multiplier MUST be rejected before allocation or effects.
// NDF-END: PTO-TDEQUANT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TDEQUANT() => TileOperation
begin
    return TileOperation_TDEQUANT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypesLegal_TDEQUANT(
    source_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return (source_type == TileDataType_S8 ||
            source_type == TileDataType_U8) &&
           destination_type == TileDataType_FP32;
end;

pure func InstructionContractDefaultMultiplier_TDEQUANT() => Word
begin
    return Zeros{PTO_XLEN} + 0x3f800000;
end;

pure func InstructionContractDefaultZeroPoint_TDEQUANT() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractScaleLegal_TDEQUANT(scale: Word) => boolean
begin
    return TileQuantizationScaleLegal(scale);
end;

pure func InstructionContractZeroPointLegal_TDEQUANT(
    zero_point: Word,
    source_type: TileDataType) => boolean
begin
    return TileQuantizationZeroPointLegal(
        zero_point,
        source_type);
end;

readonly func InstructionContractOperandsLegal_TDEQUANT(
    destination: TileIndex,
    source: TileIndex,
    multiplier: Word,
    zero_point: Word,
    control: NumericExecutionControl) => boolean
begin
    return TileOperandsLegal_TDEQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
end;

readonly func InstructionContractHandler_TDEQUANT() => TileSemanticHandler
begin
    return TileHandler_TDEQUANT;
end;

func InstructionContractExecute_TDEQUANT(
    destination: TileIndex,
    source: TileIndex,
    multiplier: Word,
    zero_point: Word,
    control: NumericExecutionControl)
begin
    assert InstructionContractOperandsLegal_TDEQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
    TDEQUANT(
        destination,
        source,
        multiplier,
        zero_point,
        control);
end;
// DOC-END: operation
