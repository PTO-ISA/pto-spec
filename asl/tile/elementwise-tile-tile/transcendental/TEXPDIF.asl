// PTO-INSTRUCTION: {"assembly":["TEXPDIF <bundle operands>"],"block":["BSTART.SFU TEXPDIF, SrcOperationType","B.DATR Layout, DataType, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[117],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","DataType","PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpdif","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":29,"legality_handler":"TileOperandsLegal_ExecuteTileExpdif","mode":0,"name":"TEXPDIF","operands":[{"field":"destination0","role":"new Local DstDataType numeric destination"},{"field":"source0","role":"persistent Local SrcOperationType minuend"},{"field":"source1","role":"persistent Local SrcOperationType subtrahend"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x01D","semantic_handler":"ExecuteTileExpdif","state_effects":["operand:destination0:new-local-DstDataType-destination","operand:source0:persistent-local-SrcOperationType-minuend","operand:source1:persistent-local-SrcOperationType-subtrahend","runtime:CurrentBundlePadValue:numeric-padding","runtime:NumericStatusFlags:profile-status"]}],"classification":["elementwise-tile-tile","transcendental"],"contract":{"block_composition":["BSTART.SFU TEXPDIF, SrcOperationType","B.DATR Layout, DataType, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"canonical_assembly":["TEXPDIF <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero and legal under the selected descriptor geometry.","Omitted B.DATR selects Layout=NORM (RowMajor), DstDataType=SrcOperationType, and PadValue=Null. When B.DATR is present, DataType=DTYPE_NONE inherits SrcOperationType and a concrete DataType selects DstDataType; encoded DataType zero selects FP64 and is not absence."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TEXPDIF, SrcOperationType; B.DATR Layout, DataType, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile0, SrcTile1, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["Malformed Local bindings, B.IOR or B.IOS presence, extra bindings, unsupported or reserved type pairs, packed or width-changing source carriers, invalid source encodings, undefined source contents, layout or logical-shape mismatch, invalid dimensions, or illegal source descriptors raise Fault_TileLegality before effects.","An unrepresentable destination shape, insufficient TSize/capacity, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before publication.","Rejection publishes no destination payload, padding, descriptor, or numeric status."],"field_contracts":{"B.DATR.DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"},"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"B.DATR.DataType":"DTYPE_NONE (31) inherits SrcOperationType; encoded zero selects FP64 and is not absence.","B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.DIM.LB0":"Zero is illegal because LB0 is required and ValidCol is nonzero.","B.DIM.LB1":"Omission selects ValidRow one; an explicitly encoded zero is illegal.","B.DIM.LB2":"Omission selects Col equal to ValidCol; an explicitly encoded zero is illegal."},"legality":["TEXPDIF is TEPL Mode 0 Function 29 (selector 0x01D) on SFU; 0x01C remains TFMA and 0x01E..0x01F remain reserved.","Exactly one terminating Local B.IOT supplies two ordered persistent Local numeric sources and one newly allocated Local numeric destination. B.IOR, B.IOS, additional bindings, and shared operands are illegal.","The exact legal (SrcOperationType,DstDataType) pairs are (FP16,FP16), (BF16,BF16), (FP32,FP32), (FP16,FP32), and (BF16,FP32). All other pairs reject.","Each source backing type may differ independently from SrcOperationType only when both types are non-packed, have equal element width, and TileCarrierWidthCompatible is true. Source payloads are validated and interpreted as SrcOperationType without retagging the source descriptors.","The result for every valid coordinate is natural exp(src0-src1), with source0 as minuend and source1 as subtrahend. TEXPDIF does not broadcast.","Same-type pairs perform typed SUB followed by typed natural EXP. Mixed FP16/BF16-to-FP32 pairs exactly widen both inputs to FP32 before FP32 SUB and FP32 natural EXP; widening is not TCVT and adds no conversion-inexact status.","Only RowMajor, CUBE_M16, and CUBE_M32 are legal. CUBE_N8, Shared, unsupported layouts, and mixed operand layouts reject. Sources and destination share the selected layout and logical ValidRow x ValidCol; each descriptor's physical geometry is checked using its own backing/destination type.","B.DATR Layout, DataType, and PadValueOrByteId are the only applicable nonzero fields. CMode, RMode, Sat, Canonicalize, and unrelated fields are illegal.","PE_MASK=0000 is a strict no-op before source descriptor reads, destination allocation, numeric status, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local DstDataType numeric destination"},{"field":"source0","role":"persistent Local SrcOperationType minuend"},{"field":"source1","role":"persistent Local SrcOperationType subtrahend"}],"ordering":["For nonzero participation, decode and validate commands, dimensions, type pair, source descriptors/carriers/definedness/encodings, destination size/capacity/name allocation, and destination geometry before result publication.","Snapshot both complete sources before computing results. Legal same-width source/destination aliasing observes read-old/write-new behavior; source Tiles remain unchanged.","For each valid element, OR SUB and EXP status; OR status across elements. Apply destination padding and publish the full destination descriptor, payload, definedness, and accumulated status atomically."],"standalone_opcode":false,"state_effects":["For every valid logical coordinate compute exp(src0-src1) using the shared typed EXPDIF numeric owner and the selected natural-EXP profile.","Mixed FP16/BF16-to-FP32 results use exact widening before FP32 subtraction; the destination has independently derived FP32 geometry and capacity.","Apply the selected PadValue outside the valid result rectangle, then atomically publish destination state and accumulated numeric status."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-TILE-MODEL-EXECUTION-EXPDIF","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS"],"engine":"SFU","id":"PTO-TILE-TEXPDIF","mnemonic":"TEXPDIF","summary":"Compute natural exp(src0-src1) elementwise over two full-shape Local Tiles.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TEXPDIF-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TEXPDIF MUST accept exactly (FP16,FP16), (BF16,BF16), (FP32,FP32),
// (FP16,FP32), and (BF16,FP32) as (SrcOperationType,DstDataType). Omitted
// B.DATR or DTYPE_NONE MUST inherit the source operation type for the
// destination; encoded DataType zero MUST select FP64 and reject. Exactly one
// terminating Local B.IOT MUST provide two ordered sources and one destination;
// B.IOR and B.IOS MUST be absent. Each source
// backing type MAY independently reinterpret as SrcOperationType only when
// both types are non-packed, equal-width, and carrier-compatible; validation
// and numeric interpretation MUST use SrcOperationType without retagging.
// Same-type pairs MUST perform typed SUB then natural EXP. Mixed FP16/BF16 to
// FP32 MUST exactly widen both operands before FP32 SUB and natural EXP. The
// operation MUST validate RowMajor, CUBE_M16, or CUBE_M32 descriptors using
// each operand's own data type while matching logical dimensions and layout.
// Complete source snapshots, status accumulation, padding, and destination
// state MUST publish atomically. Rejection MUST publish no partial effects;
// PE_MASK=0000 MUST be a strict no-op before source descriptor reads.
// NDF-END: PTO-TEXPDIF-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TEXPDIF() => TileOperation
begin
    return TileOperation_TEXPDIF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TEXPDIF(
    source_operation_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return TileExpdifTypePairLegal(
        source_operation_type, destination_type);
end;

readonly func InstructionContractOperandsLegal_TEXPDIF(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpdif(
        destination, source0, source1);
end;

readonly func InstructionContractHandler_TEXPDIF() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpdif;
end;

func InstructionContractExecute_TEXPDIF(
    destination: TileIndex,
    source0: TileIndex,
    source1: TileIndex)
begin
    ExecuteTileExpdif(destination, source0, source1);
end;
// DOC-END: operation
