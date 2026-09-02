// PTO-INSTRUCTION: {"assembly":["MSCATTER_MASK <bundle operands>"],"block":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[88],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.MSCATTER.MASK","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","CMode"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER_MASK","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_MSCATTER_MASK","name":"MSCATTER_MASK","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"Row-mode GM stride in elements; zero in Elem mode"},{"field":"source0","role":"source"},{"field":"source1","role":"relative-row-indices"},{"field":"source2","role":"exact-predicate-mask"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER_MASK","state_effects":["operand:address:base-address","operand:scalar0:gm-row-stride-elements","operand:source0:source","operand:source1:CMode-selected-relative-indices","operand:source2:exact-predicate-mask"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["MSCATTER_MASK <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects Layout=NORM; every other B.DATR field must remain zero.","B.DATR CMode=0 selects Row mode and CMode=1 selects Elem mode; codes 2..5 are inapplicable. Row mode uses a canonical row-major 1 x ValidRow S32/U32 IndexTile and consumes RegSrc1 as a GM row stride in elements. Elem mode uses a row-major S32/U32 IndexTile matching the data valid shape, requires RegSrc1 to encode zero, and treats each index as a relative element displacement from BaseGPR."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR or LB0, malformed or unterminated B.IOT stream, undefined source, source DataType mismatch, non-integer IndexTile, mask value other than zero or one, shape or layout mismatch, invalid dimensions, or packed transfer DataType, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before effects.","Only exact-one lanes generate addresses. Every enabled address is probed before the first store or event; an enabled-lane fault produces no partial write or event, while a disabled lane cannot fault from its ignored index.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{"B.DATR.CMode":{"ref":"PTO-FIELD-BLOCK-CMODE"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.CMode":"Row mode: one relative row index per data row.","B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero.","B.IOR.RegSrc1":"The architectural zero register supplies stride zero and is illegal because the row stride must be at least ValidCol."},"legality":["MSCATTER_MASK is selected only by BSTART.MSCATTER.MASK function 7 in the TLSU selector space; it has no standalone opcode.","Exactly two Local B.IOT records supply DataTile plus IndexTile and then MaskTile with the sole last marker. Neither record has a destination or TSize; B.IOS and additional bindings are illegal.","DataTile physical Col equals LB2. IndexTile and MaskTile may use different physical shapes outside the common valid rectangle.","Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 reject because the block carries no nibble selector.","PE_MASK is common across both B.IOT records. PE_MASK=0000 is a strict no-op before schema, predicate, GPR, address, permission, event, or memory checks.","B.DATR applicability allows only Layout.","DataTile must match resolved ValidRow x ValidCol, physical Col, selected Layout, and BSTART DataType.","MaskTile must match DataTile valid shape and layout and contain only exact zero-or-one predicates.","For indexed TLSU, B.DATR CMode accepts only Row=0 and Elem=1; CMode 2..5 raises Fault_TileLegality before address generation or effects.","Row mode requires a canonical row-major 1 x ValidRow S32/U32 IndexTile and a RegSrc1 row-stride value no smaller than ValidCol.","Elem mode requires a row-major S32/U32 IndexTile matching the data valid shape and requires B.IOR RegSrc1, RegSrc2, and RegDst to encode zero."],"memory_effects":["Row mode stores data coordinate (r,c) at BaseGPR + (IndexTile[0,r] * row_stride_elements + c) * sizeof(DataType).","Elem mode stores data coordinate (r,c) at BaseGPR + IndexTile[r,c] * sizeof(DataType).","A zero mask value performs no address generation, translation, permission check, store, or memory event. Physical source elements outside ValidRow x ValidCol also have no effect.","All enabled lanes are preflighted before stores. Duplicate or overlapping enabled targets have an implementation-defined final winner."],"operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"per-PE private-GPR GM row stride in elements"},{"field":"source0","role":"source data"},{"field":"source1","role":"relative row indices"},{"field":"source2","role":"exact zero-or-one predicate mask"}],"ordering":["Enabled stores participate in the common memory-order domain; no lane or inter-PE issue order is guaranteed.","B.CATR.atomic=1 makes the complete block effect non-interleavable but does not define an internal enabled-lane order or duplicate-address winner.","Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight."],"standalone_opcode":false,"state_effects":["All three source descriptors and payloads persist unchanged after success or rejection.","On success only enabled-lane memory and event state changes; MSCATTER_MASK allocates no destination Tile."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MSCATTER-MASK","mnemonic":"MSCATTER_MASK","summary":"Scatter Local data through explicit Row or Elem relative-index mode.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MSCATTER-MASK-PREDICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MaskTile MUST use packed predicate storage and every valid predicate bit
// MUST be defined. A zero bit MUST suppress address generation, translation,
// permission checks, stores, and events; a one bit MUST enable the
// corresponding CMode-selected signed-or-unsigned relative-index store.
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
// with an S32 or U32 IndexTile. Row mode MUST use one relative row index per
// data row and apply StrideGPR; Elem mode MUST use one relative element
// displacement per coordinate and require the stride selector to be zero.
// The operation MUST preserve raw carrier bits and reject packed transfer data.
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

pure func InstructionContractSupportsRowAndElemIndices_MSCATTER_MASK()
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
