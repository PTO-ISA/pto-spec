// PTO-INSTRUCTION: {"assembly":["TROWEXPANDSUB <bundle operands>"],"block":["BSTART.SFU TROWEXPANDSUB, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[46],"catalog_records":[{"arguments":[{"constant":"TileExpand_SUB"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TROWEXPANDSUB","operands":[{"field":"destination0","role":"new Local same-type numeric destination"},{"field":"source0","role":"persistent Local full-shape numeric source"},{"field":"source1","role":"persistent Local one-column broadcast source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x046","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:new-local-same-type-destination","operand:source0:persistent-local-full-shape-source","operand:source1:persistent-local-one-column-broadcast-source","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["reduce-and-expand","row-expansion"],"contract":{"block_composition":["BSTART.SFU TROWEXPANDSUB, DataType","B.DATR PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TROWEXPANDSUB <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","For every valid destination element, compute source0[r,c] - BroadcastTile[r,0] at the selected element width.","Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TSUB typed operation."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TROWEXPANDSUB, DataType; B.DATR PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, non-row-major source, undefined source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects.","An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.","All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.DIM.LB0":"Zero is illegal because LB0 is required and ValidCol is nonzero.","B.DIM.LB1":"Omission selects ValidRow one; an explicitly encoded zero is illegal.","B.DIM.LB2":"Omission selects Col equal to ValidCol; an explicitly encoded zero is illegal."},"legality":["TROWEXPANDSUB is selected by the TEPL raw encoding carrier Mode 2 Function 6; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.","Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent one-column broadcast source, and one newly allocated Local destination.","The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.","The destination and both sources use exactly the selected DataType.","The broadcast source has ValidRow equal to the destination, the orthogonal valid extent equal to one, and physical Col equal to one.","The full-shape source and destination have identical physical and valid geometry equal to the B.DIM-derived geometry.","Every source is a fully defined row-major numeric Tile with valid numeric encodings.","PadValueOrByteId is the only applicable B.DATR field. B.IOR and B.IOS are illegal.","All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local same-type numeric destination"},{"field":"source0","role":"persistent Local full-shape numeric source"},{"field":"source1","role":"persistent Local one-column broadcast source"}],"ordering":["Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.","All source payloads are snapshotted before result construction; sources persist and legal aliases use read-old/write-new behavior.","Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For every valid destination element, compute source0[r,c] - BroadcastTile[r,0] at the selected element width.","Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TSUB typed operation.","Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.","Publish the complete renamed destination atomically after every element succeeds."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"engine":"SFU","id":"PTO-TILE-TROWEXPANDSUB","mnemonic":"TROWEXPANDSUB","summary":"Subtract a broadcast one-column vector from a full-shape source with exact typed semantics.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TROWEXPANDSUB-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TROWEXPANDSUB MUST subtract the full-shape source and one-column source across columns at the selected DataType.
// The complete bundle MUST use one terminating Local B.IOT, MUST reject
// B.IOR and B.IOS, and MUST accept only the DataTypes listed by this owner.
// Complete preflight and source snapshot MUST precede atomic result, status,
// padding, and renamed-destination publication.
// NDF-END: PTO-TROWEXPANDSUB-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWEXPANDSUB() => TileOperation
begin
    return TileOperation_TROWEXPANDSUB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TROWEXPANDSUB(
    data_type: TileDataType) => boolean
begin
    return TileA9DataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWEXPANDSUB(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_SUB,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPANDSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPANDSUB(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPANDSUB(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_SUB,
        TileAxis_Row,
        destination,
        source,
        broadcast);
end;
// DOC-END: operation
