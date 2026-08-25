// PTO-INSTRUCTION: {"assembly":["MGATHER <bundle operands>"],"block":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[91],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.MGATHER","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":4,"legality_handler":"TileOperandsLegal_MGATHER","name":"MGATHER","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:byte-displacement-indices","runtime:CurrentBundlePadValue:physical-padding"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["MGATHER <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects PadValue=Null and Layout=NORM. An explicit encoded PadValue is used for every physical destination element outside ValidRow x ValidCol.","Each IndexTile logical element is a signed or unsigned byte displacement and is added directly to the base without transfer-data-type scaling."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR, missing LB0, malformed B.IOT, non-integer IndexTile, shape mismatch, non-power-of-two physical Col, or packed four-bit transfer DataType raises Fault_TileLegality before allocation, memory events, or destination effects.","Every valid-region address is probed before the first event or destination update; any access fault leaves the destination unallocated and produces no partial event or payload effect.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["MGATHER is selected only by BSTART.MGATHER function 4 in the TLSU selector space; it has no standalone opcode.","Exactly one Local B.IOT binding supplies IndexTile and one destination, uses L=1, and carries the common PE_MASK and destination TSize. B.IOS is not accepted.","IndexTile must be allocated, fully defined, generically indexable, and use S32, U32, S64, or U64. Its ValidRow x ValidCol must equal the resolved destination valid region.","The transfer DataType may be any accepted BSTART.MGATHER DataType except E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2, whose missing nibble selector makes them reserved for indexed TLSU transfer.","Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region must contain ValidRow x ValidCol.","B.IOT PE_MASK=0000 is a strict no-op before all schema, GPR, source, dimension, allocation, and memory checks.","B.DATR applicability allows only PadValueOrByteId as PadValue and Layout."],"memory_effects":["For every valid destination coordinate, load one transfer-typed element from BaseGPR plus the sign- or zero-extended byte displacement in the corresponding IndexTile coordinate.","Probe the complete valid region before recording memory events. After successful preflight, publish the loaded valid region and pad every remaining physical destination coordinate atomically."],"operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"}],"ordering":["Selected lanes contribute load events in destination row/column order using the block memory-order attributes; no cross-PE request order is guaranteed."],"standalone_opcode":false,"state_effects":["Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.","Initialize every physical destination coordinate from the selected PadValue carrier before enabled valid-lane writes.","On success overwrite enabled valid coordinates with loaded or observed values, mark the full physical destination defined, set contents_defined=TRUE, and publish atomically."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MGATHER","mnemonic":"MGATHER","summary":"Gather GM elements at signed or unsigned byte displacements into a newly allocated Local Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MGATHER-BYTE-DISPLACEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MGATHER MUST accept non-packed B8-NP, B16, B32, or B64 transfer data with
// S32, U32, S64, or U64 IndexTile elements. It MUST interpret each index as a
// full-width byte displacement, move raw carrier bits without numeric-validity
// rejection, probe the complete valid region before effects, and define the
// full physical destination using B.DATR padding outside the valid region.
// Packed four-bit transfer DataTypes MUST reject before allocation.
// NDF-END: PTO-MGATHER-BYTE-DISPLACEMENT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MGATHER() => TileOperation
begin
    return TileOperation_MGATHER;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MGATHER() => TileSemanticHandler
begin
    return TileHandler_MGATHER;
end;

pure func InstructionContractUsesByteDisplacements_MGATHER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MGATHER()
    => boolean
begin
    return FALSE;
end;
// DOC-END: operation
