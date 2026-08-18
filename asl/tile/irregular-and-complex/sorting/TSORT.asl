// PTO-INSTRUCTION: {"assembly":["TSORT <bundle operands>"],"block":["BSTART.SFU TSORT, FP32|FP16|BF16","B.DATR all-zero (optional)","B.DIM LB0=sort_width (optional; zero or omission defaults to 32)","B.IOR Descending (optional; omission defaults to ascending)","B.IOT Local source and two new Local destinations, common PE_MASK, <last>","BSTOP"],"catalog_indices":[78],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"destination1"},{"operand":"source0"},{"operand":"sort_width"},{"operand":"flag0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TSORT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":12,"legality_handler":"TileOperandsLegal_TSORT","mode":3,"name":"TSORT","operands":[{"field":"destination0","role":"new Local sorted-value destination"},{"field":"destination1","role":"new Local U32 original-index destination"},{"field":"source0","role":"persistent Local source"},{"field":"sort_width","role":"LB0 row-group width"},{"field":"flag0","role":"ascending or descending selection"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06C","semantic_handler":"TSORT","state_effects":["operand:destination0:new-local-sorted-value-destination","operand:destination1:new-local-u32-original-index-destination","operand:source0:persistent-local-source","operand:sort_width:row-group-width","operand:flag0:ascending-or-descending","runtime:NumericStatusFlags:signaling-nan-invalid-status"]}],"classification":["irregular-and-complex","sorting"],"contract":{"block_composition":["BSTART.SFU TSORT, FP32|FP16|BF16","B.DATR all-zero (optional)","B.DIM LB0=sort_width (optional; zero or omission defaults to 32)","B.IOR Descending (optional; omission defaults to ascending)","B.IOT Local source and two new Local destinations, common PE_MASK, <last>","BSTOP"],"canonical_assembly":["TSORT <bundle operands>"],"defaults":["Omitted LB0 and encoded LB0 zero both select sort_width 32; values 1 through 64 select that exact group width.","Omitted B.IOR selects ascending order. A present RegSrc0 must contain exactly zero for ascending or one for descending; every unused selector is zero.","Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TSORT, FP32; B.DIM LB0=16; B.IOR a0; B.IOT T0, mask=1111, ->T0<TSize>; B.IOT mask=1111, <last>, ->T1<TSize>; BSTOP"],"exceptions":["Malformed or unterminated Local bindings, B.IOS, unsupported DataType, non-row-major layout, nonzero inapplicable B.DATR fields, LB1 or LB2, sort_width above 64, descending other than zero or one, undefined source data, or invalid source encoding raises Fault_TileLegality before effects.","Unrepresentable destination shape, insufficient TSize, unavailable renamed destinations, or exhausted Tile capacity raises Fault_TileAllocation before effects.","PE_MASK zero completes as a strict no-op before control reads, descriptor reads, allocation, faults, numeric status, or payload effects."],"field_contracts":{"B.IOR.RegDst":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc2":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR":"All fields zero; every nonzero field is inapplicable.","B.DIM.LB0":"Encoded zero and omission both select sort_width 32.","B.IOR":"Omission selects ascending; encoded RegSrc0 zero explicitly reads GPR0 and also selects ascending."},"legality":["TSORT uses the TEPL encoding carrier Mode 3 Function 12, canonically assembles with BSTART.SFU, and has no standalone opcode.","The complete Local binding stream supplies exactly one persistent source and two distinct newly allocated destinations. Value source and value destination are FP32, FP16, or BF16; the index destination is U32. All use the same nonzero valid shape and row-major layout.","LB1 and LB2 are absent. B.DATR is all zero. B.IOS is illegal. All B.IOT bindings use one PE_MASK.","Every valid source element is defined and has a valid encoding. Signaling NaN is a legal sortable value and records numeric invalid status rather than causing a Tile legality fault."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local sorted-value destination"},{"field":"destination1","role":"new Local U32 original-index destination"},{"field":"source0","role":"persistent Local source"},{"field":"sort_width","role":"LB0 row-group width"},{"field":"flag0","role":"ascending or descending selection"}],"ordering":["Each valid row is split from column zero into consecutive groups of sort_width; the final short group never reads padding.","Sort is stable. Numeric values precede NaNs in both directions; NaNs retain source order; signed zeros compare equal. Each U32 result is the original zero-based column offset within its group.","Complete schema, control, type, descriptor, shape, capacity, mask, allocation, definedness, and encoding preflight precedes one source snapshot. Both destinations, Null padding, numeric status, and descriptors publish atomically."],"standalone_opcode":false,"state_effects":["Sort every independent row group in the selected ascending or descending direction.","Publish reordered values and matching original within-group column indices. Signaling-NaN observation ORs NV into the sticky numeric status.","The source persists. Rejection publishes no destination, descriptor, or numeric status effect."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SORTING-SCHEMA","PTO-TILE-MODEL-EXECUTION-SORTING"],"engine":"SFU","id":"PTO-TILE-TSORT","mnemonic":"TSORT","summary":"Stably sort independent row groups and return values with original within-group U32 indices.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSORT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TSORT MUST select SFU Mode 3 Function 12 and MUST accept exactly FP32, FP16,
// and BF16. It MUST stably sort each independent valid-row group, MUST return the
// matching original within-group U32 indices, MUST place numeric values before
// NaNs in either direction, and MUST set numeric invalid status when a
// signaling NaN is observed. Omitted or zero LB0 MUST select width 32.
// NDF-END: PTO-TSORT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSORT() => TileOperation
begin
    return TileOperation_TSORT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TSORT(
    data_type: TileDataType) => boolean
begin
    return TileSortDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultSortWidth_TSORT()
    => integer {1..64}
begin
    return 32;
end;

pure func InstructionContractDefaultDescending_TSORT() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TSORT(
    destination: TileIndex,
    destination_indices: TileIndex,
    source: TileIndex,
    sort_width: integer {1..64},
    descending: boolean) => boolean
begin
    return TileOperandsLegal_TSORT(
        destination,
        destination_indices,
        source,
        sort_width,
        descending);
end;

readonly func InstructionContractHandler_TSORT() => TileSemanticHandler
begin
    return TileHandler_TSORT;
end;

func InstructionContractExecute_TSORT(
    destination: TileIndex,
    destination_indices: TileIndex,
    source: TileIndex,
    sort_width: integer {1..64},
    descending: boolean)
begin
    assert InstructionContractOperandsLegal_TSORT(
        destination,
        destination_indices,
        source,
        sort_width,
        descending);
    TSORT(
        destination,
        destination_indices,
        source,
        sort_width,
        descending);
end;
// DOC-END: operation
