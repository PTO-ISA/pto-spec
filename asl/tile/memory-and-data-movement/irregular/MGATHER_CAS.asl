// PTO-INSTRUCTION: {"assembly":["MGATHER_CAS <bundle operands>"],"block":["BSTART.MGATHER.CAS DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, ExpectedTile, mask=PE_MASK","B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[89],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.MGATHER.CAS","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER_CAS","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":8,"legality_handler":"TileOperandsLegal_MGATHER_CAS","name":"MGATHER_CAS","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"scalar0","role":"GM row stride in elements"},{"field":"source0","role":"indices"},{"field":"source1","role":"expected"},{"field":"source2","role":"replacement"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER_CAS","state_effects":["operand:destination0:observed-old-values","operand:address:base-address","operand:scalar0:gm-row-stride-elements","operand:source0:logical-linear-element-indices","operand:source1:expected-values","operand:source2:replacement-values","runtime:CurrentBundlePadValue:physical-padding"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MGATHER.CAS DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, ExpectedTile, mask=PE_MASK","B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["MGATHER_CAS <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects PadValue=Null and Layout=NORM. The pad value defines every physical destination element outside ValidRow x ValidCol.","Each IndexTile logical element is a signed or unsigned logical linear element index. ValidCol splits it into a logical row and column; RegSrc1 replaces ValidCol as the GM row stride before transfer-element-size scaling."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR, missing LB0, malformed two-command B.IOT sequence, non-integer IndexTile, shape or type mismatch, packed four-bit transfer DataType, or invalid dimensions, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before destination allocation, atomic events, or memory writes.","Every valid-region read and write address is probed before the first compare-and-swap. Any access fault leaves the destination unallocated and produces no partial atomic event, memory write, or payload effect.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero.","B.IOR.RegSrc1":"The architectural zero register supplies stride zero and is illegal because the row stride must be at least ValidCol."},"legality":["MGATHER_CAS is selected only by BSTART.MGATHER.CAS function 8 in the TLSU selector space; it has no standalone opcode.","Exactly two Local B.IOT bindings are required. The first supplies IndexTile and ExpectedTile without a destination and has L=0. The second supplies ReplacementTile and a newly allocated destination and has L=1. Both carry one common PE_MASK; B.IOS is not accepted.","IndexTile must be allocated, fully defined, generically indexable, and use S32, U32, S64, or U64. Each logical element is interpreted as a signed or unsigned logical linear element index.","ExpectedTile and ReplacementTile must be allocated, fully defined, use the selected transfer DataType, and match the resolved ValidRow x ValidCol. Comparison uses their encoded element values.","Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.","Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region contains ValidRow x ValidCol.","B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, dimension, allocation, address, or fault checks.","B.DATR applicability allows only PadValueOrByteId as PadValue and Layout.","The B.IOR row stride is nonzero and no smaller than ValidCol; an invalid stride rejects before address probes or effects."],"memory_effects":["For each valid coordinate, atomically read the selected transfer-typed element from the address obtained by splitting the logical linear index by ValidCol, applying row_stride_elements to the row, and scaling the resulting element offset by the transfer element size; compare it with ExpectedTile, conditionally store ReplacementTile, and place the observed old value in the destination.","All lane addresses are preflighted before the first atomic event. Duplicate addresses are legal and their per-lane atomic operations serialize in an implementation-defined order; no row-major or other fixed order is architectural.","After every selected lane completes, publish the observed valid region and pad every remaining physical destination coordinate atomically."],"operands":[{"field":"destination0","role":"observed-old-values destination"},{"field":"address","role":"base-address"},{"field":"scalar0","role":"per-PE private-GPR GM row stride in elements"},{"field":"source0","role":"logical linear element indices"},{"field":"source1","role":"expected values"},{"field":"source2","role":"replacement values"}],"ordering":["Each lane is one atomic read-modify-write governed by the block memory-order attributes.","Duplicate-address lanes serialize in an implementation-defined order. No additional inter-PE order is guaranteed.","Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight."],"standalone_opcode":false,"state_effects":["Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.","Initialize every physical destination coordinate from the selected PadValue carrier before enabled valid-lane writes.","On success overwrite enabled valid coordinates with loaded or observed values, mark the full physical destination defined, set contents_defined=TRUE, and publish atomically."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MGATHER-CAS","mnemonic":"MGATHER_CAS","summary":"Atomically compare and conditionally replace GM elements addressed by signed or unsigned logical linear element indices.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MGATHER-CAS-ATOMIC-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MGATHER_CAS MUST accept non-packed B8-NP, B16, B32, or B64 transfer data with
// S32, U32, S64, or U64 logical linear element indices and preserve raw carrier
// bits without numeric-validity rejection. Each valid lane MUST perform one
// atomic compare-and-swap at the address derived from the signed or unsigned
// logical linear element index supplied by IndexTile and MUST place
// the value observed by that atomic operation in the corresponding destination
// element. Duplicate-address lanes MUST serialize in an implementation-defined
// order and MUST NOT expose a fixed row-major ordering requirement.
// NDF-END: PTO-MGATHER-CAS-ATOMIC-001
// NDF-BEGIN: PTO-MGATHER-CAS-PUBLICATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MGATHER_CAS MUST preflight every valid-region read and write address before
// its first atomic effect. On success it MUST publish one fully defined
// destination whose non-valid physical elements contain the selected pad value.
// NDF-END: PTO-MGATHER-CAS-PUBLICATION-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MGATHER_CAS() => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MGATHER_CAS() => TileSemanticHandler
begin
    return TileHandler_MGATHER_CAS;
end;

pure func InstructionContractUsesLogicalElementIndices_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MGATHER_CAS()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesMemory_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
