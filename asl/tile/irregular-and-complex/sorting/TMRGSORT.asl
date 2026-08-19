// PTO-INSTRUCTION: {"assembly":["TMRGSORT <bundle operands>"],"block":["BSTART.SFU TMRGSORT, FP32|FP16","B.DATR all-zero (optional)","B.IOR Descending (optional; omission defaults to ascending)","B.IOT two Local sources and one new Local destination, common PE_MASK, <last>","BSTOP"],"catalog_indices":[79],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"flag0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMRGSORT","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":13,"legality_handler":"TileOperandsLegal_TMRGSORT","mode":3,"name":"TMRGSORT","operands":[{"field":"destination0","role":"new Local merged destination"},{"field":"source0","role":"persistent sorted Local left source"},{"field":"source1","role":"persistent sorted Local right source"},{"field":"flag0","role":"ascending or descending selection"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x06D","semantic_handler":"TMRGSORT","state_effects":["operand:destination0:new-local-merged-destination","operand:source0:persistent-sorted-local-left-source","operand:source1:persistent-sorted-local-right-source","operand:flag0:ascending-or-descending","runtime:NumericStatusFlags:signaling-nan-invalid-status"]}],"classification":["irregular-and-complex","sorting"],"contract":{"block_composition":["BSTART.SFU TMRGSORT, FP32|FP16","B.DATR all-zero (optional)","B.IOR Descending (optional; omission defaults to ascending)","B.IOT two Local sources and one new Local destination, common PE_MASK, <last>","BSTOP"],"canonical_assembly":["TMRGSORT <bundle operands>"],"defaults":["Omitted B.IOR selects ascending order. A present RegSrc0 must contain exactly zero for ascending or one for descending; every unused selector is zero.","Every B.DIM is omitted. Destination ValidCol is the sum of source ValidCol values and physical Col is the smallest representable power of two that covers that sum.","Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TMRGSORT, FP16; B.IOR a0; B.IOT T0, T1, mask=1111, <last>, ->T0<TSize>; BSTOP"],"exceptions":["Malformed or unterminated Local bindings, B.IOS, any B.DIM, unsupported DataType, non-row-major or nonsingle-row sources, nonzero inapplicable B.DATR fields, descending other than zero or one, undefined or invalid source data, or a source not sorted in the selected direction raises Fault_TileLegality before effects.","A combined width above the architectural physical-column range, insufficient TSize, an unavailable renamed destination, or exhausted Tile capacity raises Fault_TileAllocation before effects.","PE_MASK zero completes as a strict no-op before control reads, source reads, sortedness checks, allocation, faults, numeric status, or payload effects."],"field_contracts":{"B.IOR.RegDst":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc2":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR":"All fields zero; every nonzero field is inapplicable.","B.DIM":"Every dimension carrier is absent; zero is not an encoded TMRGSORT operand.","B.IOR":"Omission selects ascending; encoded RegSrc0 zero explicitly reads GPR0 and also selects ascending."},"legality":["TMRGSORT uses the TEPL encoding carrier Mode 3 Function 13, canonically assembles with BSTART.SFU, and has no standalone opcode.","The complete Local binding stream supplies exactly two persistent nonempty single-row sorted sources and one newly allocated destination. All are row-major FP32 or FP16 with one common DataType.","The source streams are sorted in the direction selected by B.IOR before execution. B.DATR is all zero, every B.DIM is absent, B.IOS is illegal, and every B.IOT uses one PE_MASK.","Every valid source element is defined and has a valid encoding. Signaling NaN is a legal merge value and records numeric invalid status rather than causing a Tile legality fault."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local merged destination"},{"field":"source0","role":"persistent sorted Local left source"},{"field":"source1","role":"persistent sorted Local right source"},{"field":"flag0","role":"ascending or descending selection"}],"ordering":["Merge is stable. Equal values select the left source first; numeric values precede NaNs in both directions; NaNs retain per-source order and left-source precedence; signed zeros compare equal.","Destination ValidRow is one and ValidCol is the sum of both source ValidCol values. It contains the complete selected-order merge.","Complete schema, direction, source ordering, type, descriptor, shape, capacity, mask, allocation, definedness, and encoding preflight precedes both source snapshots. Destination, Null padding, numeric status, and descriptor publish atomically."],"standalone_opcode":false,"state_effects":["Stably merge two already sorted single-row streams in ascending or descending order.","Signaling-NaN observation ORs NV into the sticky numeric status. Both sources persist.","Rejection publishes no destination, descriptor, or numeric status effect."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SORTING-SCHEMA","PTO-TILE-MODEL-EXECUTION-SORTING"],"engine":"SFU","id":"PTO-TILE-TMRGSORT","mnemonic":"TMRGSORT","summary":"Stably merge two sorted single-row Local streams into one newly allocated Local destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMRGSORT-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TMRGSORT MUST select SFU Mode 3 Function 13 and MUST accept exactly FP32
// and FP16. It MUST reject a source not sorted in the selected direction before
// effects, MUST merge equal values from the left source first, MUST place
// numeric values before NaNs in either direction, and MUST set numeric invalid
// status when a signaling NaN is observed.
// NDF-END: PTO-TMRGSORT-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMRGSORT() => TileOperation
begin
    return TileOperation_TMRGSORT;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TMRGSORT(
    data_type: TileDataType) => boolean
begin
    return TileSortDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultDescending_TMRGSORT() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TMRGSORT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    descending: boolean) => boolean
begin
    return TileOperandsLegal_TMRGSORT(
        destination,
        source_left,
        source_right,
        descending);
end;

readonly func InstructionContractHandler_TMRGSORT() => TileSemanticHandler
begin
    return TileHandler_TMRGSORT;
end;

func InstructionContractExecute_TMRGSORT(
    destination: TileIndex,
    source_left: TileIndex,
    source_right: TileIndex,
    descending: boolean)
begin
    assert InstructionContractOperandsLegal_TMRGSORT(
        destination,
        source_left,
        source_right,
        descending);
    TMRGSORT(
        destination,
        source_left,
        source_right,
        descending);
end;
// DOC-END: operation
