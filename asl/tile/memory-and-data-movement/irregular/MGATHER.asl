// PTO-INSTRUCTION: {"assembly":["MGATHER <bundle operands>"],"block":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[85],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.MGATHER","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout","CMode"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":4,"legality_handler":"TileOperandsLegal_MGATHER","name":"MGATHER","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"scalar0","role":"Row-mode GM stride in elements; zero in Elem mode"},{"field":"source0","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER","state_effects":["operand:destination0:destination","operand:address:base-address","operand:scalar0:gm-row-stride-elements","operand:source0:CMode-selected-relative-indices","runtime:CurrentBundlePadValue:physical-padding"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["MGATHER <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects PadValue=Null and Layout=NORM. An explicit encoded PadValue is used for every physical destination element outside ValidRow x ValidCol.","B.DATR CMode=0 selects Row mode and CMode=1 selects Elem mode; codes 2..5 are inapplicable. Row mode uses a canonical row-major 1 x ValidRow S32/U32 IndexTile and consumes RegSrc1 as a GM row stride in elements. Elem mode uses a row-major S32/U32 IndexTile matching the data valid shape, requires RegSrc1 to encode zero, and treats each index as a relative element displacement from BaseGPR."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR, missing LB0, malformed B.IOT, non-integer IndexTile, shape mismatch, non-power-of-two physical Col, or packed four-bit transfer DataType, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before allocation, memory events, or destination effects.","Every valid-region address is probed before the first event or destination update; any access fault leaves the destination unallocated and produces no partial event or payload effect.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{"B.DATR.CMode":{"ref":"PTO-FIELD-BLOCK-CMODE"},"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.DATR.CMode":"Row mode: one relative row index per data row.","B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero.","B.IOR.RegSrc1":"The architectural zero register supplies stride zero and is illegal because the row stride must be at least ValidCol."},"legality":["MGATHER is selected only by BSTART.MGATHER function 4 in the TLSU selector space; it has no standalone opcode.","Exactly one Local B.IOT binding supplies IndexTile and one destination, uses L=1, and carries the common PE_MASK and destination TSize. B.IOS is not accepted.","The transfer DataType may be any accepted BSTART.MGATHER DataType except E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2, whose missing nibble selector makes them reserved for indexed TLSU transfer.","Destination physical Rows are derived from TSize, physical Col, and transfer DataType. Rows and Col are powers of two and the physical region must contain ValidRow x ValidCol.","B.IOT PE_MASK=0000 is a strict no-op before all schema, GPR, source, dimension, allocation, and memory checks.","B.DATR applicability allows only PadValueOrByteId as PadValue and Layout.","For indexed TLSU, B.DATR CMode accepts only Row=0 and Elem=1; CMode 2..5 raises Fault_TileLegality before address generation or effects.","Row mode requires a canonical row-major 1 x ValidRow S32/U32 IndexTile and a RegSrc1 row-stride value no smaller than ValidCol.","Elem mode requires a row-major S32/U32 IndexTile matching the data valid shape and requires B.IOR RegSrc1, RegSrc2, and RegDst to encode zero."],"memory_effects":["Row mode accesses data coordinate (r,c) at BaseGPR + (IndexTile[0,r] * row_stride_elements + c) * sizeof(DataType).","Elem mode accesses data coordinate (r,c) at BaseGPR + IndexTile[r,c] * sizeof(DataType).","Probe the complete valid region before recording memory events. After successful preflight, publish the loaded valid region and pad every remaining physical destination coordinate atomically."],"operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"scalar0","role":"per-PE private-GPR GM row stride in elements"},{"field":"source0","role":"relative row indices"}],"ordering":["Selected lanes contribute load events in destination row/column order using the block memory-order attributes; no cross-PE request order is guaranteed.","Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight."],"standalone_opcode":false,"state_effects":["Allocate a new Local destination descriptor using B.IOT TSize, resolved dimensions, selected transfer DataType, selected Layout, and PE_MASK.","Initialize every physical destination coordinate from the selected PadValue carrier before enabled valid-lane writes.","On success overwrite enabled valid coordinates with loaded or observed values, mark the full physical destination defined, set contents_defined=TRUE, and publish atomically."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MGATHER","mnemonic":"MGATHER","summary":"Gather GM data through explicit Row or Elem relative-index mode.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MGATHER-BYTE-DISPLACEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MGATHER MUST accept non-packed B8-NP, B16, B32, or B64 transfer data with
// S32 or U32 IndexTile elements. CMode=Row MUST require a canonical row-major
// 1 x ValidRow IndexTile and address (r,c) as
// BaseGPR + (IndexTile[0,r] * StrideGPR + c) * sizeof(DataType). CMode=Elem
// MUST require an IndexTile matching the destination valid shape, require the
// stride selector to be zero, and address (r,c) as
// BaseGPR + IndexTile[r,c] * sizeof(DataType). The operation MUST preserve raw
// carrier bits and preflight the complete valid region before effects.
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

pure func InstructionContractSupportsRowAndElemIndices_MGATHER()
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
