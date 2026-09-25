// PTO-INSTRUCTION: {"assembly":["TROWEXPANDEXPDIF <bundle operands>"],"block":["BSTART.SFU TROWEXPANDEXPDIF, DataType","B.DATR Layout, DataType, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[51],"catalog_records":[{"arguments":[{"constant":"TileExpand_EXPDIF"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","DataType","PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":11,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TROWEXPANDEXPDIF","operands":[{"field":"destination0","role":"new Local destination with DstDataType"},{"field":"source0","role":"persistent Local full-shape numeric source"},{"field":"source1","role":"persistent Local row-broadcast source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x04B","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:new-local-DstDataType-destination","operand:source0:persistent-local-full-shape-SrcDataType-source","operand:source1:persistent-local-one-column-SrcDataType-broadcast-source","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["reduce-and-expand","row-expansion"],"contract":{"block_composition":["BSTART.SFU TROWEXPANDEXPDIF, DataType","B.DATR Layout, DataType, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TROWEXPANDEXPDIF <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects DstDataType=SrcDataType and PadValue=Null. When B.DATR is present, DTYPE_NONE inherits SrcDataType, a concrete DataType selects DstDataType, and encoded DataType zero selects FP64 and is never absence. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TROWEXPANDEXPDIF, SrcDataType; B.DATR Layout, DataType, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType or EXPDIF pair, unsupported or mixed layout, undefined source element, mismatched source geometry, or invalid consumed arithmetic/EXPDIF operation-view encoding raises Fault_TileLegality before effects. Ignored extra broadcast elements remain defined but are not encoding-validated.","An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.","All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"},"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.DIM.LB0":"Zero is illegal because LB0 is required and ValidCol is nonzero.","B.DIM.LB1":"Omission selects ValidRow one; an explicitly encoded zero is illegal.","B.DIM.LB2":"Omission selects Col equal to ValidCol; an explicitly encoded zero is illegal.","B.DATR.DataType":"DTYPE_NONE (31) inherits BSTART SrcDataType; concrete DataType selects DstDataType; encoded zero selects FP64 and is not absence."},"legality":["TROWEXPANDEXPDIF and TCOLEXPANDEXPDIF accept exactly (FP16,FP16), (BF16,BF16), (FP32,FP32), (FP16,FP32), and (BF16,FP32) as (SrcDataType,DstDataType) pairs.","BSTART DataType selects SrcDataType; omitted B.DATR or explicit DataType=DTYPE_NONE selects DstDataType=SrcDataType, while a concrete B.DATR DataType selects DstDataType. Each source backing may differ from SrcDataType only through an equal-width non-packed carrier view; raw bits are interpreted as SrcDataType without retagging or numeric conversion.","Mixed FP16/BF16 to FP32 widens the operation-view source bits exactly to FP32 before FP32 subtraction and FP32 exponential. Same-type pairs retain their selected type.","The destination is newly allocated with DstDataType; no destination alias or source descriptor retag is introduced.","The broadcast source has ValidRows equal to destination.ValidRows and ValidColumns >= 1; only BroadcastTile[r,0] supplies the row value, while later valid columns remain defined but are ignored.","The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.","All source valid regions are fully defined and Numeric in the selected RowMajor, CUBE_M16, or CUBE_M32 layout. Full-shape and selected broadcast operation-view payloads must have valid SrcDataType encodings; ignored extra broadcast elements need definedness but are not encoding-validated.","Layout, PadValueOrByteId, and DataType are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.","All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local DstDataType destination"},{"field":"source0","role":"persistent Local full-shape numeric source"},{"field":"source1","role":"persistent Local row broadcast source interpreted through SrcDataType; only column zero supplies values"}],"ordering":["Complete schema, attribute, dimension, source/destination type-pair, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.","All source payloads are snapshotted before result construction; sources persist and same-type legal aliases use read-old/write-new behavior.","Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For each destination [r,c], interpret source0[r,c] and BroadcastTile[r,0] as SrcDataType. For mixed FP16/BF16 to FP32 pairs, widen both exactly to FP32, then subtract and exponentiate at FP32; same-type pairs retain the existing sequence.","The subtraction and exponential stages apply in sequence and their numeric-status flags are accumulated into one transaction.","Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.","Publish the complete renamed destination atomically after every element succeeds."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"engine":"SFU","id":"PTO-TILE-TROWEXPANDEXPDIF","mnemonic":"TROWEXPANDEXPDIF","summary":"Exponentiate the SrcDataType difference using the selected row broadcast element.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TROWEXPANDEXPDIF-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TROWEXPANDEXPDIF keeps the existing legal (SrcDataType,DstDataType) pairs and numeric sequence. BSTART selects SrcDataType; omitted B.DATR or DTYPE_NONE selects DstDataType=SrcDataType, and a concrete B.DATR DataType selects DstDataType. Each source descriptor keeps its backing DataType; a differing source backing is legal only for an equal-width non-packed carrier and its raw bits are interpreted as SrcDataType without retagging or conversion.
// The full-shape source has the destination valid geometry. The broadcast geometry requires ValidRows equal to destination.ValidRows and ValidColumns >= 1; only BroadcastTile[r,0] is consumed. All source valid regions remain fully defined. Operation-view encoding validation covers every full-shape source element and only the selected broadcast elements; ignored extra broadcast elements are defined but not encoding-validated.
// Existing EXPDIF type-pair widening, arithmetic, status, layout, PE-mask, padding, alias, snapshot, and atomic-publication rules remain unchanged.
// NDF-END: PTO-TROWEXPANDEXPDIF-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWEXPANDEXPDIF() => TileOperation
begin
    return TileOperation_TROWEXPANDEXPDIF;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TROWEXPANDEXPDIF(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_FP32;
end;

readonly func InstructionContractOperandsLegal_TROWEXPANDEXPDIF(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPANDEXPDIF() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPANDEXPDIF(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPANDEXPDIF(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_EXPDIF,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;
// DOC-END: operation
