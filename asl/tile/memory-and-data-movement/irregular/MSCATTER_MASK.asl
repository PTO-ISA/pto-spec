// PTO-INSTRUCTION: {"assembly":["MSCATTER_MASK <bundle operands>"],"block":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[94],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.MSCATTER.MASK","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER_MASK","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_MSCATTER_MASK","name":"MSCATTER_MASK","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source"},{"field":"source1","role":"byte-displacement-indices"},{"field":"source2","role":"exact-predicate-mask"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER_MASK","state_effects":["operand:address:base-address","operand:source0:source","operand:source1:byte-displacement-indices","operand:source2:exact-predicate-mask"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["MSCATTER_MASK <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the byte-address base; zero selects architectural base address zero. Unused B.IOR fields must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects Layout=NORM; every other B.DATR field must remain zero.","Each IndexTile element is a signed or unsigned byte displacement. Each MaskTile element must be exactly zero or one."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR or LB0, malformed or unterminated B.IOT stream, undefined source, source DataType mismatch, non-integer IndexTile, mask value other than zero or one, shape or layout mismatch, invalid dimensions, or packed transfer DataType raises Fault_TileLegality before effects.","Only exact-one lanes generate addresses. Every enabled address is probed before the first store or event; an enabled-lane fault produces no partial write or event, while a disabled lane cannot fault from its ignored index.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["MSCATTER_MASK is selected only by BSTART.MSCATTER.MASK function 7 in the TLSU selector space; it has no standalone opcode.","Exactly two Local B.IOT records supply DataTile plus IndexTile and then MaskTile with the sole last marker. Neither record has a destination or TSize; B.IOS and additional bindings are illegal.","All three sources are allocated and fully defined, share ValidRow x ValidCol and Layout, and persist after execution. DataTile DataType equals BSTART DataType; IndexTile is integer; MaskTile valid elements are exactly zero or one.","DataTile physical Col equals LB2. IndexTile and MaskTile may use different physical shapes outside the common valid rectangle.","Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 reject because the block carries no nibble selector.","PE_MASK is common across both B.IOT records. PE_MASK=0000 is a strict no-op before schema, predicate, GPR, address, permission, event, or memory checks.","B.DATR applicability allows only Layout."],"memory_effects":["For each valid coordinate whose MaskTile value is one, store the corresponding DataTile element to BaseGPR plus the sign- or zero-extended byte displacement in IndexTile.","A zero mask value performs no address generation, translation, permission check, store, or memory event. Physical source elements outside ValidRow x ValidCol also have no effect.","All enabled lanes are preflighted before stores. Duplicate or overlapping enabled targets have an implementation-defined final winner."],"operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source data"},{"field":"source1","role":"byte-displacement indices"},{"field":"source2","role":"exact zero-or-one predicate mask"}],"ordering":["Enabled stores participate in the common memory-order domain; no lane or inter-PE issue order is guaranteed.","B.CATR.atomic=1 makes the complete block effect non-interleavable but does not define an internal enabled-lane order or duplicate-address winner."],"standalone_opcode":false,"state_effects":["All three source descriptors and payloads persist unchanged after success or rejection.","On success only enabled-lane memory and event state changes; MSCATTER_MASK allocates no destination Tile."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MSCATTER-MASK","mnemonic":"MSCATTER_MASK","summary":"Scatter exact-one source lanes to GM at signed or unsigned byte displacements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MSCATTER-MASK-PREDICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Every valid MaskTile element MUST be exactly zero or one. Zero MUST suppress
// address generation, translation, permission checks, stores, and events; one
// MUST enable the corresponding signed-or-unsigned byte-displacement store.
// NDF-END: PTO-MSCATTER-MASK-PREDICATE-001
// NDF-BEGIN: PTO-MSCATTER-MASK-DUPLICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Duplicate enabled addresses MUST have an implementation-defined winner.
// B.CATR.atomic MUST NOT impose an internal enabled-lane order; it only makes
// the complete block effect non-interleavable.
// NDF-END: PTO-MSCATTER-MASK-DUPLICATE-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MSCATTER_MASK() => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MSCATTER_MASK() => TileSemanticHandler
begin
    return TileHandler_MSCATTER_MASK;
end;

pure func InstructionContractUsesByteDisplacements_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER_MASK()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
