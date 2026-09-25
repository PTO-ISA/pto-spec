// PTO-INSTRUCTION: {"assembly":["TROWEXPAND <bundle operands>"],"block":["BSTART.SFU TROWEXPAND, DataType","B.DATR Layout, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[44],"catalog_records":[{"arguments":[{"constant":"TileExpand_COPY"},{"constant":"TileAxis_Row"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","PadValueOrByteId"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTileExpand","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":4,"legality_handler":"TileOperandsLegal_ExecuteTileExpand","mode":2,"name":"TROWEXPAND","operands":[{"field":"destination0","role":"new Local same-type numeric destination"},{"field":"source0","role":"persistent Local row-broadcast source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x044","semantic_handler":"ExecuteTileExpand","state_effects":["operand:destination0:new-local-same-type-destination","operand:source0:persistent-local-row-broadcast-source","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["reduce-and-expand","row-expansion"],"contract":{"block_composition":["BSTART.SFU TROWEXPAND, DataType","B.DATR Layout, PadValue (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TROWEXPAND <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow=1. Omitted LB2 selects Col=ValidCol; every explicitly present dimension must be nonzero.","Omitted B.DATR selects PadValue=Null. Explicit PadValue 00, 01, 10, and 11 select Zero, Max, Min, and Null.","For every valid destination element, copy BroadcastTile[r,0] bit-for-bit.","The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TROWEXPAND, DataType; B.DATR Layout, PadValue (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT BroadcastTile, mask=PE_MASK, <last>, ->DstTile<TSize>; BSTOP"],"exceptions":["A malformed binding stream, B.IOR or B.IOS presence, missing or zero dimension, unsupported DataType, unsupported or mixed layout, undefined source element, or mismatched source geometry raises Fault_TileLegality before effects. COPY forms do not validate numeric encodings.","An unrepresentable destination shape, insufficient TSize, unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before destination publication.","All valid results, numeric status, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"field_contracts":{"B.DATR.PadValueOrByteId":{"ref":"PTO-FIELD-BLOCK-PADVALUE-OR-BYTEID"}},"field_zero_meanings":{"B.DATR.PadValueOrByteId":"Zero padding when B.DATR is present; omission selects Null.","B.DIM.LB0":"Zero is illegal because LB0 is required and ValidCol is nonzero.","B.DIM.LB1":"Omission selects ValidRow one; an explicitly encoded zero is illegal.","B.DIM.LB2":"Omission selects Col equal to ValidCol; an explicitly encoded zero is illegal."},"legality":["TROWEXPAND is selected by the TEPL raw encoding carrier Mode 2 Function 4; canonical execution-engine assembly is BSTART.SFU and there is no standalone opcode.","Exactly one terminating Local B.IOT supplies one persistent row broadcast source with at least one valid column and one newly allocated Local destination; no full-shape second source exists.","The exact legal DataTypes are FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, S64, S32, S16, S8, U64, U32, U16, and U8.","The destination DataType is the BSTART operation DataType. The broadcast source backing may differ only through an equal-width non-packed carrier view.","The broadcast source has ValidRows equal to destination.ValidRows and ValidColumns >= 1; only logical column zero supplies values, while later valid columns remain defined but ignored.","The destination geometry is the B.DIM-derived geometry.","The source valid region is fully defined and Numeric in the selected RowMajor, CUBE_M16, or CUBE_M32 layout; COPY does not validate arithmetic encodings.","Layout and PadValueOrByteId are the only applicable nonzero B.DATR fields. B.IOR and B.IOS are illegal.","All operands share one PE_MASK; PE_MASK=0000 is a strict no-op before descriptor reads, allocation, faults, status, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local same-type numeric destination"},{"field":"source0","role":"persistent Local row broadcast source; only column zero supplies values"}],"ordering":["Complete schema, attribute, dimension, type, descriptor, source-definedness, source-encoding, mask, capacity, name-allocation, and storage preflight precedes every source snapshot.","All source payloads are snapshotted before result construction; sources persist and legal aliases use read-old/write-new behavior.","Numeric status, all valid results, selected padding definedness, and the renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For every valid destination element, copy the raw operation-view bits of BroadcastTile[r,0] bit-for-bit.","The copy performs no conversion, rounding, saturation, canonicalization, or numeric-status update.","Apply the selected PadValue to physical destination coordinates outside the valid result rectangle.","Publish the complete renamed destination atomically after every element succeeds."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-MODEL-LEGALITY-REDUCTION-AND-EXPANSION"],"engine":"SFU","id":"PTO-TILE-TROWEXPAND","mnemonic":"TROWEXPAND","summary":"Copy the first logical column of a row broadcast source bit-for-bit into a new Local destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TROWEXPAND-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TROWEXPAND copies raw operation-view bits from broadcast[r,0] into each valid destination element along the row axis. BSTART selects the destination operation DataType. The broadcast backing DataType may differ only when widths match and neither carrier is packed; the descriptor remains unchanged and no numeric conversion occurs.
// The broadcast geometry requires ValidRows equal to destination.ValidRows and ValidColumns >= 1. Only logical column zero supplies values; other logical broadcast elements remain required to be defined but are ignored. The entire broadcast source valid region remains required to be defined; COPY has no numeric-encoding validation or numeric-status effect.
// The complete BSTART, B.DIM, B.DATR, layout, PE-mask, padding, alias, snapshot, and atomic-publication rules remain unchanged.
// NDF-END: PTO-TROWEXPAND-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TROWEXPAND() => TileOperation
begin
    return TileOperation_TROWEXPAND;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TROWEXPAND(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TROWEXPAND(
    destination: TileIndex,
    broadcast: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Row,
        destination,
        broadcast,
        broadcast);
end;

readonly func InstructionContractHandler_TROWEXPAND() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;

func InstructionContractExecute_TROWEXPAND(
    destination: TileIndex,
    broadcast: TileIndex)
begin
    assert InstructionContractOperandsLegal_TROWEXPAND(
        destination,
        broadcast);
    ExecuteTileExpand(
        TileExpand_COPY,
        TileAxis_Row,
        destination,
        broadcast,
        broadcast);
end;
// DOC-END: operation
