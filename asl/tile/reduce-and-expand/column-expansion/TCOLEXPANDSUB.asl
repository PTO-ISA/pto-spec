// PTO-INSTRUCTION: {"assembly":["TCOLEXPANDSUB <bundle operands>"],"block":["BSTART.SFU TCOLEXPANDSUB, DataType","B.DATR Layout, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[60],"catalog_records":[{"arguments":[{"constant":"TileExpand_SUB"},{"constant":"TileAxis_Column"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":22,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TCOLEXPANDSUB","operands":[{"field":"destination0","role":"new Local same-type numeric destination"},{"field":"source0","role":"persistent Local full-shape numeric source"},{"field":"source1","role":"persistent Local column-broadcast source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x056","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:new-local-same-type-destination","operand:source0:persistent-local-full-shape-source","operand:source1:persistent-local-column-broadcast-source","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["reduce-and-expand","column-expansion"],"contract":{"block_composition":["BSTART.SFU TCOLEXPANDSUB, DataType","B.DATR Layout, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TCOLEXPANDSUB <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","For every valid destination element, compute source0[r,c] - BroadcastTile[0,c] at the selected element width.","Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TSUB typed operation."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TCOLEXPANDSUB, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT SrcTile, BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType or EXPDIF pair, unsupported or mixed layout, undefined source element, mismatched source geometry, or invalid consumed arithmetic/EXPDIF operation-view encoding raises Fault_TileLegality before effects. Ignored extra broadcast elements remain defined but are not encoding-validated.","An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.","All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.DIM.LB0":"Zero is illegal because LB0 is required and ValidCol is nonzero.","B.DIM.LB1":"Omission selects ValidRow one; an explicitly encoded zero is illegal.","B.DIM.LB2":"Omission selects Col equal to ValidCol; an explicitly encoded zero is illegal."},"legality":["TCOLEXPANDSUB is selected by the TEPL raw encoding carrier Mode 2 Function 22; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.","Exactly one terminating Local B.IOT supplies one persistent full-shape source, one persistent column broadcast source with at least one valid row, and one newly allocated Local destination.","The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.","The BSTART DataType is both the source operation DataType and destination DataType. Each source backing DataType may differ only through an equal-width non-packed carrier view; raw bits are interpreted under the operation DataType without retagging or numeric conversion.","The broadcast source has ValidRows >= 1 and ValidColumns equal to destination.ValidColumns; only BroadcastTile[0,c] supplies values, while later valid rows remain defined but ignored.","The full-shape source and destination have identical logical valid geometry and the selected layout; physical geometry is derived per layout.","All source valid regions are fully defined and Numeric in the selected RowMajor, CUBE_M16, or CUBE_M32 layout. Full-shape and selected broadcast operation-view payloads must have valid encodings; ignored extra broadcast elements need definedness but are not encoding-validated.","Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.","All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local same-type numeric destination"},{"field":"source0","role":"persistent Local full-shape numeric source"},{"field":"source1","role":"persistent Local column broadcast source; only row zero supplies values through the BSTART operation view"}],"ordering":["Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.","All source payloads are snapshotted before result construction; sources persist and legal aliases use read-old/write-new behavior.","Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For every valid destination element, compute source0[r,c] - operation-view BroadcastTile[0,c] at the selected element width.","Integer width, floating rounding, exceptional values, signed-zero behavior, and numeric status are exactly the corresponding TSUB typed operation.","Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.","Publish the complete renamed destination atomically after every element succeeds."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"engine":"SFU","id":"PTO-TILE-TCOLEXPANDSUB","mnemonic":"TCOLEXPANDSUB","summary":"Subtract a first-row column-broadcast source from a full-shape source with exact typed semantics.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCOLEXPANDSUB-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCOLEXPANDSUB uses BSTART DataType as both the source operation DataType and destination DataType. Each Tile source descriptor keeps its backing DataType; a differing backing is legal only for equal-width non-packed carriers, whose raw bits are interpreted under the selected operation type without retagging or numeric conversion.
// The full-shape source has the destination valid geometry. The broadcast geometry requires ValidRows >= 1 and ValidColumns equal to destination.ValidColumns; only BroadcastTile[0,c] supplies the broadcast value. All source valid regions remain fully defined. Numeric encoding validation uses the selected operation DataType for the full-shape source and selected broadcast elements; broadcast rows after row zero are defined but are not encoding-validated.
// The complete BSTART, B.DIM, B.DATR, layout, PE-mask, integer DIV, numeric-status, padding, alias, snapshot, and atomic-publication rules remain unchanged.
// NDF-END: PTO-TCOLEXPANDSUB-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCOLEXPANDSUB() => TileOperation
begin
    return TileOperation_TCOLEXPANDSUB;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TCOLEXPANDSUB(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TCOLEXPANDSUB(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_SUB,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;

readonly func InstructionContractHandler_TCOLEXPANDSUB() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TCOLEXPANDSUB(
    destination: TileIndex,
    source: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TCOLEXPANDSUB(
        destination,
        source,
        broadcast);
    ExecuteTileExpand(
        TileExpand_SUB,
        TileAxis_Column,
        destination,
        source,
        broadcast);
end;
// DOC-END: operation
