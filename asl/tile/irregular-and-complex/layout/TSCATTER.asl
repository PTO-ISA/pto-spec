// PTO-INSTRUCTION: {"assembly":["TSCATTER <bundle operands>"],"block":["BSTART.SFU TSCATTER, ValueDataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[82],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TSCATTER","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":16,"legality_handler":"TileOperandsLegal_TSCATTER","mode":3,"name":"TSCATTER","operands":[{"field":"destination0","role":"new zero-initialized Local value destination"},{"field":"source0","role":"persistent Local value source"},{"field":"source1","role":"persistent Local S16, U16, S32, U32, S64, or U64 row-index source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x070","semantic_handler":"TSCATTER","state_effects":["operand:destination0:new-zero-initialized-local-destination","operand:source0:persistent-value-source","operand:source1:persistent-row-index-source","runtime:typed-zero:unselected-valid-and-padding"]}],"classification":["irregular-and-complex","layout"],"contract":{"block_composition":["BSTART.SFU TSCATTER, ValueDataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TSCATTER <bundle operands>"],"defaults":["LB0 is required and supplies nonzero destination ValidCol; omitted LB1 selects destination ValidRow=1 and omitted LB2 selects physical Col=ValidCol.","Omitted B.DATR retains row-major destination layout; an assigned legal Layout changes only destination physical placement. PadValueOrByteId is encoded zero and means typed positive or integer zero for this operation; every other B.DATR field remains zero.","Before scatter writes, every physical destination element is initialized to the selected value DataType's positive or integer zero and is defined."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TSCATTER, U16; B.DIM LB0=2; B.DIM LB1=4; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP"],"exceptions":["Malformed bindings, B.IOR, B.IOS, unsupported value/index pair, zero or mismatched source shape, destination-column mismatch, negative or out-of-range index, duplicate destination coordinate, undefined source, invalid consumed encoding, reserved Layout, or insufficient destination capacity raises the applicable Tile fault before effects.","PE_MASK=0000 is a strict no-op before Tile reads, index and duplicate checks, allocation, faults, zero initialization, or payload effects."],"field_contracts":{},"field_zero_meanings":{"B.DATR.Layout":"Encoded zero selects row-major destination placement.","B.DATR.PadValueOrByteId":"Encoded zero selects typed positive or integer zero initialization for the complete physical destination.","B.DIM.LB1":"Omission selects ValidRow=1; an explicitly encoded zero is not a legal nonzero dimension.","B.DIM.LB2":"Omission selects physical Col=ValidCol; an explicitly encoded zero is not a legal physical column count."},"legality":["TSCATTER uses the TEPL encoding carrier Mode 3 Function 16, is canonically assembled with BSTART.SFU, and has no standalone opcode.","Exactly one terminating Local B.IOT supplies one persistent value source, one persistent row-index source, and one newly allocated destination; B.IOR and B.IOS are illegal.","Every non-packed B8-NP, B16, B32, or B64 value pairs with every S16, U16, S32, U32, S64, or U64 index.","The two sources have the same nonzero valid shape. Destination ValidCol equals source ValidCol and destination ValidRow is nonzero.","Every signed index is nonnegative and every index is less than destination ValidRow. No two source coordinates may select the same destination coordinate [index[r,c],c].","Both source valid rectangles are fully defined and validly encoded. All three bindings use the same PE_MASK; any nonzero subset is legal."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new zero-initialized Local value destination"},{"field":"source0","role":"persistent Local value source"},{"field":"source1","role":"persistent Local S16, U16, S32, U32, S64, or U64 row-index source"}],"ordering":["Complete schema, descriptor, type-pair, dimension, layout, capacity, index-range, duplicate-coordinate, and source-definedness preflight precedes source snapshots.","Both sources are snapshotted before zero initialization and scatter evaluation; complete destination payload, physical definedness, and descriptor publish atomically."],"standalone_opcode":false,"state_effects":["Initialize every physical destination coordinate to typed positive or integer zero.","For every source coordinate [r,c], read k=index[r,c] and write source[r,c] bit-for-bit to destination[k,c].","Both sources persist, no previous destination value is read, and rejection publishes no destination state."]},"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT","PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TSCATTER","mnemonic":"TSCATTER","summary":"Scatter values to distinct destination rows selected independently at each source coordinate.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSCATTER-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSCATTER MUST accept every non-packed B8-NP, B16, B32, or B64 value type with
// every S16, U16, S32, U32, S64, or U64 index type. Each index element is a
// logical destination-row selector at the current column. It MUST reject
// negative, out-of-range, or duplicate destination coordinates before effects,
// move raw value carrier bits without numeric-validity rejection, initialize
// the complete physical destination to typed zero, and publish all scattered
// writes atomically.
// NDF-END: PTO-TSCATTER-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSCATTER() => TileOperation
begin
    return TileOperation_TSCATTER;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractOperandsLegal_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TSCATTER(destination, source, indices);
end;

readonly func InstructionContractHandler_TSCATTER() => TileSemanticHandler
begin
    return TileHandler_TSCATTER;
end;

func InstructionContractExecute_TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TSCATTER(
        destination,
        source,
        indices);
    TSCATTER(destination, source, indices);
end;
// DOC-END: operation
