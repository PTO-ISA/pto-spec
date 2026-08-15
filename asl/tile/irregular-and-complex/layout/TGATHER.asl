// PTO-INSTRUCTION: {"assembly":["TGATHER <bundle operands>"],"block":["BSTART.SFU TGATHER, ValueDataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[81],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TGATHER","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":15,"legality_handler":"TileOperandsLegal_TGATHER","mode":3,"name":"TGATHER","operands":[{"field":"destination0","role":"new Local value destination"},{"field":"source0","role":"persistent Local value source"},{"field":"source1","role":"persistent Local S32 or U32 row-index source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06F","semantic_handler":"TGATHER","state_effects":["operand:destination0:new-local-value-destination","operand:source0:persistent-value-source","operand:source1:persistent-row-index-source","runtime:TilePad_Null:physical-padding"]}],"classification":["irregular-and-complex","layout"],"contract":{"block_composition":["BSTART.SFU TGATHER, ValueDataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT ValueSrc, IndexSrc, mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TGATHER <bundle operands>"],"defaults":["LB0 is required and supplies nonzero destination ValidCol; omitted LB1 selects destination ValidRow=1 and omitted LB2 selects physical Col=ValidCol.","Omitted B.DATR retains row-major destination layout; an assigned legal Layout changes only destination physical placement. PadValueOrByteId, secondary DataType, CMode, RMode, Sat, and Canonicalize remain zero.","Physical destination coordinates outside the valid rectangle are undefined Null padding."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TGATHER, U16; B.DIM LB0=2; B.DIM LB1=2; B.IOT ValueSrc, IndexSrc, mask=1111, <last>, ->Dst<2>; BSTOP"],"exceptions":["Malformed bindings, B.IOR, B.IOS, unsupported value or index DataType, zero or mismatched valid shape, insufficient source columns, negative or out-of-range index, undefined index, undefined selected source element, invalid consumed encoding, reserved Layout, or insufficient destination capacity raises the applicable Tile fault before effects.","PE_MASK=0000 is a strict no-op before Tile reads, index checks, allocation, faults, or payload effects."],"field_contracts":{},"field_zero_meanings":{"B.DATR.Layout":"Encoded zero selects row-major destination placement.","B.DIM.LB1":"Omission selects ValidRow=1; an explicitly encoded zero is not a legal nonzero dimension.","B.DIM.LB2":"Omission selects physical Col=ValidCol; an explicitly encoded zero is not a legal physical column count."},"legality":["TGATHER uses the TEPL encoding carrier Mode 3 Function 15, is canonically assembled with BSTART.SFU, and has no standalone opcode.","Exactly one terminating Local B.IOT supplies one persistent value source, one persistent row-index source, and one newly allocated destination; B.IOR and B.IOS are illegal.","Value source and destination use the same one of FP32, FP16, S32, S16, U32, or U16. The index source is exactly S32 or U32.","Index and destination valid shapes are equal and nonzero. The value source has at least destination ValidCol columns.","Every signed index is nonnegative and every index is less than source ValidRow. The complete index rectangle and every selected source[value,row,column] element are defined and validly encoded.","All three bindings use the same PE_MASK; any nonzero subset is legal."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local value destination"},{"field":"source0","role":"persistent Local value source"},{"field":"source1","role":"persistent Local S32 or U32 row-index source"}],"ordering":["Complete schema, descriptor, type, dimension, layout, capacity, index-range, and referenced-definedness preflight precedes source snapshots.","Both source payloads are snapshotted before result construction; complete destination payload, definedness, Null padding, and descriptor publish atomically."],"standalone_opcode":false,"state_effects":["For every destination coordinate [r,c], read k=index[r,c] and copy source[k,c] bit-for-bit to destination[r,c].","Indices select logical source rows and never flatten, wrap, clamp, or select another column.","Both sources persist and rejection publishes no destination state."]},"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT","PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TGATHER","mnemonic":"TGATHER","summary":"Gather values from source rows selected independently at each destination coordinate.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TGATHER-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TGATHER MUST interpret each S32 or U32 index element as a logical source-row
// selector at the current column. It MUST reject negative, out-of-range, or
// undefined references before effects, snapshot both sources, and publish one
// complete destination with Null physical padding atomically.
// NDF-END: PTO-TGATHER-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGATHER() => TileOperation
begin
    return TileOperation_TGATHER;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractOperandsLegal_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex) => boolean
begin
    return TileOperandsLegal_TGATHER(destination, source, indices);
end;

readonly func InstructionContractHandler_TGATHER() => TileSemanticHandler
begin
    return TileHandler_TGATHER;
end;

func InstructionContractExecute_TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    assert InstructionContractOperandsLegal_TGATHER(
        destination,
        source,
        indices);
    TGATHER(destination, source, indices);
end;
// DOC-END: operation
