// PTO-INSTRUCTION: {"assembly":["TPARTADD <bundle operands>"],"block":["BSTART.SFU TPARTADD, FP32|FP16|BF16|S32|S16|S8|U32|U16|U8","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional; omission defaults to 1)","B.DIM LB2=Col (optional; omission defaults to ValidCol)","B.IOT exactly two persistent Local sources and one new Local destination, common PE_MASK, <last>","BSTOP"],"catalog_indices":[83],"catalog_records":[{"arguments":[{"constant":"TilePartial_ADD"},{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"ExecuteTilePartial","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":17,"legality_handler":"TileOperandsLegal_ExecuteTilePartial","mode":3,"name":"TPARTADD","operands":[{"field":"destination0","role":"new Local union destination"},{"field":"source0","role":"persistent Local left source anchored at origin"},{"field":"source1","role":"persistent Local right source anchored at origin"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x071","semantic_handler":"ExecuteTilePartial","state_effects":["operand:destination0:new-local-union-destination","operand:source0:persistent-origin-anchored-left-source","operand:source1:persistent-origin-anchored-right-source","runtime:NumericStatusFlags:overlap-operation-status","runtime:TilePad_Null:physical-padding"]}],"classification":["irregular-and-complex","union"],"contract":{"block_composition":["BSTART.SFU TPARTADD, FP32|FP16|BF16|S32|S16|S8|U32|U16|U8","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional; omission defaults to 1)","B.DIM LB2=Col (optional; omission defaults to ValidCol)","B.IOT exactly two persistent Local sources and one new Local destination, common PE_MASK, <last>","BSTOP"],"canonical_assembly":["TPARTADD <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; omitted LB2 selects physical Col equal to ValidCol.","B.DATR, B.IOR, and B.IOS are absent. Both sources and the destination use the BSTART DataType and row-major layout.","Each source rectangle is anchored at origin. A coordinate covered by exactly one source is copied bit-for-bit; a coordinate covered by both sources applies the selected typed operation. Physical padding is Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TPARTADD, S16; B.DIM LB0=16; B.IOT Left, Right, mask=1111, <last>, ->Dst<1>; BSTOP"],"exceptions":["Missing, surplus, shared, scalar, data-attribute, malformed, unterminated, mixed-mask, type, layout, shape, undefined-source, or invalid-floating-encoding input raises Fault_TileLegality before effects.","An unrepresentable destination shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before effects.","PE_MASK zero completes as a strict no-op before descriptor reads, source reads, allocation, faults, numeric status, padding, or payload effects."],"field_contracts":{},"field_zero_meanings":{"B.DIM.LB1":"Omission selects one valid row.","B.DIM.LB2":"Omission selects physical Col equal to ValidCol.","B.DATR":"The command is absent; encoded zero is not a TPART descriptor."},"legality":["TPARTADD uses the TEPL encoding carrier Mode 3 Function 17, canonically assembles with BSTART.SFU, and has no standalone opcode.","Exactly two persistent nonempty Local sources and one newly allocated Local destination are supplied by a terminated B.IOT stream. B.DATR, B.IOR, and B.IOS are illegal.","Source and destination DataType is exactly one of FP32, FP16, BF16, S32, S16, S8, U32, U16, or U8. All are row-major and use one PE_MASK.","Both source valid rectangles are origin-anchored, fit within ValidRow by ValidCol, and at least one source covers the entire destination valid rectangle. Thus no valid destination coordinate is uncovered.","Every valid source element is defined; floating encodings are valid."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local union destination"},{"field":"source0","role":"persistent Local left source anchored at origin"},{"field":"source1","role":"persistent Local right source anchored at origin"}],"ordering":["Complete schema, type, shape, capacity, coverage, mask, destination-name, source-definedness, source-encoding, and allocation preflight precedes both source snapshots.","The sources persist. The result payload, sticky numeric flags, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["At an overlap coordinate, typed addition is applied with the common DataType's exact arithmetic, ordering, rounding, NaN, signed-zero, and status behavior.","At a coordinate covered by only one source, that source element is copied bit-for-bit without arithmetic status.","Every physical destination coordinate outside ValidRow by ValidCol is undefined Null padding."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-PARTIAL-SCHEMA","PTO-TILE-MODEL-EXECUTION-COMPLEX"],"engine":"SFU","id":"PTO-TILE-TPARTADD","mnemonic":"TPARTADD","summary":"Form the origin-anchored union of two Local Tiles and add overlap elements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TPARTADD-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TPARTADD MUST select SFU Mode 3 Function 17. It MUST form the origin-
// anchored union of exactly two persistent Local sources and MUST apply typed addition
// only where both sources cover a coordinate. A coordinate covered by one
// source MUST be copied bit-for-bit. B.DATR, B.IOR, and B.IOS MUST be absent.
// NDF-END: PTO-TPARTADD-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TPARTADD() => TileOperation
begin
    return TileOperation_TPARTADD;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TPARTADD(
    data_type: TileDataType) => boolean
begin
    return TilePartialDataTypeSupported(data_type);
end;

readonly func InstructionContractOperandsLegal_TPARTADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex) => boolean
begin
    return TileOperandsLegal_ExecuteTilePartial(
        TilePartial_ADD,
        destination,
        source_left,
        source_right);
end;

readonly func InstructionContractHandler_TPARTADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTilePartial;
end;

func InstructionContractExecute_TPARTADD(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex)
begin
    assert InstructionContractOperandsLegal_TPARTADD(
        destination,
        source_left,
        source_right);
    ExecuteTilePartial(
        TilePartial_ADD,
        destination,
        source_left,
        source_right);
end;
// DOC-END: operation
