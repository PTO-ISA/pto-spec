// PTO-INSTRUCTION: {"assembly":["MSCATTER <bundle operands>"],"block":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[86],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.MSCATTER","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout","CMode"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":5,"legality_handler":"TileOperandsLegal_MSCATTER","name":"MSCATTER","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"Row-mode GM stride in elements; zero in Elem mode"},{"field":"source0","role":"source"},{"field":"source1","role":"relative-row-indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER","state_effects":["operand:address:base-address","operand:scalar0:gm-row-stride-elements","operand:source0:source","operand:source1:CMode-selected-relative-indices"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["MSCATTER <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects Layout=NORM. PadValueOrByteId and every other B.DATR field must remain zero.","B.DATR CMode=0 selects Row mode and CMode=1 selects Elem mode; codes 2..5 are inapplicable. Row mode uses a canonical row-major 1 x ValidRow S32/U32 IndexTile and consumes RegSrc1 as a GM row stride in elements. Elem mode uses a row-major S32/U32 IndexTile matching the data valid shape, requires RegSrc1 to encode zero, and treats each index as a relative element displacement from BaseGPR."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR, missing LB0, malformed B.IOT, undefined source, source DataType mismatch, non-integer IndexTile, shape or layout mismatch, invalid dimensions, or packed four-bit transfer DataType, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before memory events or writes.","Every valid-region address is generated and probed before the first store or event; any access fault produces no partial memory or event effect.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{"B.DATR.CMode":{"ref":"PTO-FIELD-BLOCK-CMODE"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.CMode":"Row mode: one relative row index per data row.","B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero.","B.IOR.RegSrc1":"The architectural zero register supplies stride zero and is illegal because the row stride must be at least ValidCol."},"legality":["MSCATTER is selected only by BSTART.MSCATTER function 5 in the TLSU selector space; it has no standalone opcode.","Exactly one terminating Local B.IOT supplies DataTile and IndexTile with no destination or TSize. B.IOS and additional Tile bindings are not accepted.","Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.","B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, dimension, address, permission, event, or memory checks.","B.DATR applicability allows only Layout.","DataTile must match resolved ValidRow x ValidCol, physical Col, selected Layout, and BSTART DataType.","For indexed TLSU, B.DATR CMode accepts only Row=0 and Elem=1; CMode 2..5 raises Fault_TileLegality before address generation or effects.","Row mode requires a canonical row-major 1 x ValidRow S32/U32 IndexTile and a RegSrc1 row-stride value no smaller than ValidCol.","Elem mode requires a row-major S32/U32 IndexTile matching the data valid shape and requires B.IOR RegSrc1, RegSrc2, and RegDst to encode zero."],"memory_effects":["Row mode stores data coordinate (r,c) at BaseGPR + (IndexTile[0,r] * row_stride_elements + c) * sizeof(DataType).","Elem mode stores data coordinate (r,c) at BaseGPR + IndexTile[r,c] * sizeof(DataType).","Only ValidRow x ValidCol is written; source physical elements outside the valid rectangle have no memory effect.","All valid-lane addresses are preflighted before stores. Duplicate or overlapping target addresses have an implementation-defined final winner."],"operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"per-PE private-GPR GM row stride in elements"},{"field":"source0","role":"source data"},{"field":"source1","role":"relative row indices"}],"ordering":["No lane or inter-PE issue order is architecturally guaranteed.","B.CATR.atomic=1 makes the complete block memory effect non-interleavable but does not define an internal lane order or a duplicate-address winner.","Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight."],"standalone_opcode":false,"state_effects":["Source Tile descriptors and payloads persist unchanged after success or rejection.","On success only memory and memory-event state change; MSCATTER allocates no destination Tile."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MSCATTER","mnemonic":"MSCATTER","summary":"Scatter Local data through explicit Row or Elem relative-index mode.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MSCATTER-BYTE-DISPLACEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MSCATTER MUST accept non-packed B8-NP, B16, B32, or B64 transfer data with
// S32 or U32 IndexTile elements. CMode=Row MUST require a canonical row-major
// 1 x ValidRow IndexTile and address (r,c) as
// BaseGPR + (IndexTile[0,r] * StrideGPR + c) * sizeof(DataType). CMode=Elem
// MUST require an IndexTile matching the source valid shape, require the stride
// selector to be zero, and address (r,c) as
// BaseGPR + IndexTile[r,c] * sizeof(DataType). The operation MUST preflight
// every valid lane before its first store and leave source descriptors unchanged.
// NDF-END: PTO-MSCATTER-BYTE-DISPLACEMENT-001
// NDF-BEGIN: PTO-MSCATTER-DUPLICATE-ORDER-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Duplicate or overlapping target addresses MUST have an
// implementation-defined winner. B.CATR.atomic MUST NOT impose an internal
// lane order; it only makes the complete block effect non-interleavable.
// NDF-END: PTO-MSCATTER-DUPLICATE-ORDER-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_MSCATTER() => TileOperation
begin
    return TileOperation_MSCATTER;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_MSCATTER() => TileSemanticHandler
begin
    return TileHandler_MSCATTER;
end;

pure func InstructionContractSupportsRowAndElemIndices_MSCATTER()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractUsesMaskTile_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractIsAtomicMemoryOperation_MSCATTER()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractWritesMemory_MSCATTER()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
