// PTO-INSTRUCTION: {"assembly":["MGATHER_MASK <bundle operands>"],"block":["BSTART.MGATHER.MASK DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[93],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.MGATHER.MASK","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER_MASK","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_MGATHER_MASK","name":"MGATHER_MASK","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"},{"field":"source1","role":"mask"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER_MASK","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:byte-displacement-indices","operand:source1:exact-predicate-mask","runtime:CurrentBundlePadValue:inactive-and-physical-padding"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MGATHER.MASK DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["MGATHER_MASK <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects PadValue=Null and Layout=NORM. PadValue is written to disabled valid lanes and every physical destination element outside ValidRow x ValidCol.","Each IndexTile logical element is a signed or unsigned byte displacement. Each MaskTile logical element must be exactly zero or one."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR, missing LB0, malformed B.IOT, non-integer IndexTile, mask value other than zero or one, shape or layout mismatch, packed four-bit transfer DataType, or invalid dimensions raises Fault_TileLegality before destination allocation, memory events, or memory reads.","Only enabled-lane addresses are generated and probed. Every enabled lane is preflighted before the first load; any enabled-lane fault leaves the destination unallocated and produces no partial event or payload effect. Disabled lanes cannot fault from their ignored IndexTile value.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["MGATHER_MASK is selected only by BSTART.MGATHER.MASK function 6 in the TLSU selector space; it has no standalone opcode.","Exactly one terminating Local B.IOT supplies IndexTile, MaskTile, destination, TSize, and PE_MASK. B.IOS and additional Tile bindings are not accepted.","IndexTile must be allocated, fully defined, generically indexable, and use S4X2, U4X2, S8, U8, S16, U16, S32, U32, S64, or U64. Each logical element is sign- or zero-extended as a byte displacement.","MaskTile must be allocated and fully defined. Its logical shape and layout must match IndexTile and destination; every valid element is exactly zero or one.","Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.","Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region contains ValidRow x ValidCol.","B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, predicate, dimension, allocation, address, or fault checks.","B.DATR applicability allows only PadValueOrByteId as PadValue and Layout."],"memory_effects":["For each valid coordinate whose MaskTile value is one, load one transfer-typed element from BaseGPR plus the corresponding sign- or zero-extended byte displacement and record one load event.","A valid coordinate whose mask is zero performs no address generation, translation, permission check, memory access, or memory event and receives PadValue.","After complete enabled-lane preflight, publish enabled loads, disabled-lane padding, and all non-valid physical padding atomically."],"operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"byte-displacement indices"},{"field":"source1","role":"exact zero-or-one predicate mask"}],"ordering":["Enabled-lane loads participate in the PTO memory-order domain through the block aq/rl attributes.","No additional lane or inter-PE issue order is guaranteed."],"standalone_opcode":false,"state_effects":["Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.","On success the full physical destination is defined: enabled valid lanes contain loaded values and every disabled or non-valid coordinate contains PadValue."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MGATHER-MASK","mnemonic":"MGATHER_MASK","summary":"Gather enabled GM elements at byte displacements and pad disabled destination lanes.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MGATHER-MASK-PREDICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Every valid MaskTile element MUST be exactly zero or one. Zero MUST suppress
// address generation, translation, permission checks, memory access, and
// memory events for that lane and MUST select PadValue for the destination.
// One MUST enable the signed-or-unsigned byte-displacement load.
// NDF-END: PTO-MGATHER-MASK-PREDICATE-001
// NDF-BEGIN: PTO-MGATHER-MASK-PUBLICATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MGATHER_MASK MUST preflight all and only enabled addresses before its first
// load effect. On success it MUST publish one fully defined destination whose
// disabled and non-valid physical elements contain the selected pad value.
// NDF-END: PTO-MGATHER-MASK-PUBLICATION-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MGATHER_MASK() => TileOperation
begin
    return TileOperation_MGATHER_MASK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MGATHER_MASK() => TileSemanticHandler
begin
    return TileHandler_MGATHER_MASK;
end;

pure func InstructionContractUsesByteDisplacements_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER_MASK()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MGATHER_MASK()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
