// PTO-INSTRUCTION: {"assembly":["MSCATTER_MASK <bundle operands>"],"block":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[80],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.MSCATTER.MASK","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER_MASK","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_MSCATTER_MASK","name":"MSCATTER_MASK","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"GM row stride in elements"},{"field":"source0","role":"source"},{"field":"source1","role":"logical-linear-element-indices"},{"field":"source2","role":"exact-predicate-mask"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER_MASK","state_effects":["operand:address:base-address","operand:scalar0:gm-row-stride-elements","operand:source0:source","operand:source1:logical-linear-element-indices","operand:source2:exact-predicate-mask"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["MSCATTER_MASK <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects Layout=NORM; every other B.DATR field must remain zero.","Each IndexTile logical element is a signed or unsigned logical linear element index. ValidCol splits it into a logical row and column; RegSrc1 replaces ValidCol as the GM row stride before transfer-element-size scaling."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR or LB0, malformed or unterminated B.IOT stream, undefined source, source DataType mismatch, non-integer IndexTile, mask value other than zero or one, shape or layout mismatch, invalid dimensions, or packed transfer DataType, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before effects.","Only exact-one lanes generate addresses. Every enabled address is probed before the first store or event; an enabled-lane fault produces no partial write or event, while a disabled lane cannot fault from its ignored index.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero.","B.IOR.RegSrc1":"The architectural zero register supplies stride zero and is illegal because the row stride must be at least ValidCol."},"legality":["MSCATTER_MASK is selected only by BSTART.MSCATTER.MASK function 7 in the TLSU selector space; it has no standalone opcode.","Exactly two Local B.IOT records supply DataTile plus IndexTile and then MaskTile with the sole last marker. Neither record has a destination or TSize; B.IOS and additional bindings are illegal.","All three sources are allocated and fully defined, share ValidRow x ValidCol and Layout, and persist after execution. DataTile DataType equals BSTART DataType; IndexTile uses S32, U32, S64, or U64 logical linear element indices; MaskTile valid elements are exactly zero or one.","DataTile physical Col equals LB2. IndexTile and MaskTile may use different physical shapes outside the common valid rectangle.","Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 reject because the block carries no nibble selector.","PE_MASK is common across both B.IOT records. PE_MASK=0000 is a strict no-op before schema, predicate, GPR, address, permission, event, or memory checks.","B.DATR applicability allows only Layout.","The B.IOR row stride is nonzero and no smaller than ValidCol; an invalid stride rejects before address probes or effects."],"memory_effects":["For each valid coordinate whose MaskTile value is one, store the corresponding DataTile element to the address obtained by splitting the logical linear index by ValidCol, applying row_stride_elements to the row, and scaling the resulting element offset by the transfer element size.","A zero mask value performs no address generation, translation, permission check, store, or memory event. Physical source elements outside ValidRow x ValidCol also have no effect.","All enabled lanes are preflighted before stores. Duplicate or overlapping enabled targets have an implementation-defined final winner."],"operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"per-PE private-GPR GM row stride in elements"},{"field":"source0","role":"source data"},{"field":"source1","role":"logical linear element indices"},{"field":"source2","role":"exact zero-or-one predicate mask"}],"ordering":["Enabled stores participate in the common memory-order domain; no lane or inter-PE issue order is guaranteed.","B.CATR.atomic=1 makes the complete block effect non-interleavable but does not define an internal enabled-lane order or duplicate-address winner.","Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight."],"standalone_opcode":false,"state_effects":["All three source descriptors and payloads persist unchanged after success or rejection.","On success only enabled-lane memory and event state changes; MSCATTER_MASK allocates no destination Tile."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MSCATTER-MASK","mnemonic":"MSCATTER_MASK","summary":"Scatter exact-one source lanes to GM using signed or unsigned logical linear element indices.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MSCATTER-MASK-PREDICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MaskTile MUST use packed predicate storage and every valid predicate bit
// MUST be defined. A zero bit MUST suppress address generation, translation,
// permission checks, stores, and events; a one bit MUST enable the
// corresponding signed-or-unsigned logical-linear-element-index store.
// NDF-END: PTO-MSCATTER-MASK-PREDICATE-001
// NDF-BEGIN: PTO-MSCATTER-MASK-DUPLICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Duplicate enabled addresses MUST have an implementation-defined winner.
// B.CATR.atomic MUST NOT impose an internal enabled-lane order; it only makes
// the complete block effect non-interleavable.
// NDF-END: PTO-MSCATTER-MASK-DUPLICATE-001
// NDF-BEGIN: PTO-MSCATTER-MASK-TYPE-002
// ndf: kind=contract level=L1 layer=tile status=accepted
// MSCATTER_MASK MUST accept non-packed B8-NP, B16, B32, or B64 transfer data
// with S32, U32, S64, or U64 logical linear element indices. It MUST preserve raw
// carrier bits without numeric-validity rejection and MUST reject packed
// four-bit transfer DataTypes before effects.
// NDF-END: PTO-MSCATTER-MASK-TYPE-002
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

pure func InstructionContractUsesLogicalElementIndices_MSCATTER_MASK()
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
