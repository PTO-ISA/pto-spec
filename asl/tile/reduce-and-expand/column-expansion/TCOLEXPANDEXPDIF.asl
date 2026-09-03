// PTO-INSTRUCTION: {"assembly":["TCOLEXPANDEXPDIF <bundle operands>"],"block":["BSTART.SFU TCOLEXPANDEXPDIF, DataType","B.DATR DataType, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[65],"catalog_records":[{"arguments":[{"constant":"TileExpand_EXPDIF"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","DataType","PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":27,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TCOLEXPANDEXPDIF","operands":[{"field":"destination0","role":"new Local destination with DstDataType"},{"field":"source0","role":"persistent Local full-shape numeric source"},{"field":"source1","role":"persistent Local one-row broadcast source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x05B","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:new-local-DstDataType-destination","operand:source0:persistent-local-full-shape-SrcDataType-source","operand:source1:persistent-local-one-row-SrcDataType-broadcast-source","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["reduce-and-expand","column-expansion"],"contract":{"block_composition":["BSTART.SFU TCOLEXPANDEXPDIF, DataType","B.DATR DataType, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TCOLEXPANDEXPDIF <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects DstDataType=SrcDataType and PadValue=Null. When B.DATR is present, DTYPE_NONE inherits SrcDataType, a concrete DataType selects DstDataType, and encoded DataType zero selects FP64 and is never absence. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TCOLEXPANDEXPDIF, SrcDataType; B.DATR DataType, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported source/destination DataType pair, unsupported, mixed, or mismatched source layout, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.","An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.","All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.DIM.LB0":"Zero is illegal because LB0 is required and ValidCol is nonzero.","B.DIM.LB1":"Omission selects ValidRow one; an explicitly encoded zero is illegal.","B.DIM.LB2":"Omission selects Col equal to ValidCol; an explicitly encoded zero is illegal.","B.DATR.DataType":"DTYPE_NONE (31) inherits BSTART SrcDataType; concrete DataType selects DstDataType; encoded zero selects FP64 and is not absence."},"legality":["TROWEXPANDEXPDIF and TCOLEXPANDEXPDIF accept exactly (FP16,FP16), (BF16,BF16), (FP32,FP32), (FP16,FP32), and (BF16,FP32) as (SrcDataType,DstDataType) pairs.","BSTART DataType selects SrcDataType; omitted B.DATR or explicit DataType=DTYPE_NONE selects DstDataType=SrcDataType; a concrete B.DATR DataType selects DstDataType. Source0 and BroadcastTile use SrcDataType and the destination uses DstDataType.","Mixed FP16/BF16 to FP32 widens both source operands exactly to FP32 before FP32 subtraction and FP32 exponential. Same-type pairs retain their selected type.","The destination is a newly allocated FP32-capacity result for mixed pairs; no cross-type alias or reinterpret view is introduced.","The broadcast source has logical ValidRow equal to one and ValidCol equal to the destination; physical extents are derived from the selected layout.","The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.","Every source is a fully defined numeric Tile in the selected RowMajor, CUBE_M16, or CUBE_M32 layout with valid numeric encodings.","PadValueOrByteId and DataType are the only applicable B.DATR fields. B.IOR and B.IOS are illegal.","All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local DstDataType destination"},{"field":"source0","role":"persistent Local full-shape numeric source"},{"field":"source1","role":"persistent Local one-row broadcast source"}],"ordering":["Complete schema, attribute, dimension, source/destination type-pair, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.","All source payloads are snapshotted before result construction; sources persist and same-type legal aliases use read-old/write-new behavior.","Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For every valid destination element, source0 and BroadcastTile are interpreted as SrcDataType. For mixed FP16/BF16 to FP32 pairs, widen both exactly to FP32, then compute FP32 source0 - BroadcastTile and FP32 natural exponential. Same-type pairs preserve the existing selected-type sequence.","The subtraction and exponential stages apply in sequence and their numeric-status flags are accumulated into one transaction.","Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.","Publish the complete renamed destination atomically after every element succeeds."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"engine":"SFU","id":"PTO-TILE-TCOLEXPANDEXPDIF","mnemonic":"TCOLEXPANDEXPDIF","summary":"Exponentiate the typed difference between a full-shape source and a broadcast one-row vector.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCOLEXPANDEXPDIF-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCOLEXPANDEXPDIF MUST subtract the one-row SrcDataType source from the
// full-shape source down rows and MUST exponentiate at DstDataType.
// The only legal (SrcDataType,DstDataType) pairs are (FP16,FP16),
// (BF16,BF16), (FP32,FP32), (FP16,FP32), and (BF16,FP32). BSTART selects
// SrcDataType; omitted B.DATR or DataType=DTYPE_NONE inherits it, while a
// concrete B.DATR DataType selects DstDataType.
// The complete bundle MUST use one terminating Local B.IOT, MUST reject
// B.IOR and B.IOS, and MUST reject every other source/destination pair.
// Complete preflight and source snapshot MUST precede atomic result, status,
// padding, and renamed-destination publication.
// Layout 29 selects direct Local CUBE_M32 and Layout 31 selects direct Local CUBE_M16. Omitted B.DATR and Layout=NORM retain RowMajor; all Tile operands in one operation MUST use the same layout.
// NDF-END: PTO-TCOLEXPANDEXPDIF-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLEXPANDEXPDIF() => TileOperation
begin
    return TileOperation_TCOLEXPANDEXPDIF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TCOLEXPANDEXPDIF(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_FP32;
end;

readonly func InstructionContractOperandsLegal_TCOLEXPANDEXPDIF(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TCOLEXPANDEXPDIF() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TCOLEXPANDEXPDIF(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLEXPANDEXPDIF(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;
// DOC-END: operation
