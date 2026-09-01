// PTO-INSTRUCTION: {"assembly":["MSCATTER <bundle operands>"],"block":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[86],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.MSCATTER","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":5,"legality_handler":"TileOperandsLegal_MSCATTER","name":"MSCATTER","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"GM row stride in elements"},{"field":"source0","role":"source"},{"field":"source1","role":"logical-linear-element-indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER","state_effects":["operand:address:base-address","operand:scalar0:gm-row-stride-elements","operand:source0:source","operand:source1:logical-linear-element-indices"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["MSCATTER <bundle operands>"],"defaults":["B.IOR is required. RegSrc0 names the PE-private absolute GPR containing the GM base address, RegSrc1 names the nonzero GM row stride in elements, and RegSrc2 plus RegDst must encode zero.","LB0 is required and supplies ValidCol. Omitted LB1 defaults ValidRow to one. Omitted LB2 defaults physical Col to ValidCol. Explicit zero is illegal for every present dimension.","Omitted B.DATR selects Layout=NORM. PadValueOrByteId and every other B.DATR field must remain zero.","Each IndexTile logical element is a signed or unsigned logical linear element index. ValidCol splits it into a logical row and column; RegSrc1 replaces ValidCol as the GM row stride before transfer-element-size scaling."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["A missing B.IOR, missing LB0, malformed B.IOT, undefined source, source DataType mismatch, non-integer IndexTile, shape or layout mismatch, invalid dimensions, or packed four-bit transfer DataType, zero row stride, or row stride smaller than ValidCol raises Fault_TileLegality before memory events or writes.","Every valid-region address is generated and probed before the first store or event; any access fault produces no partial memory or event effect.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"},"B.IOR.RegSrc1":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero.","B.IOR.RegSrc1":"The architectural zero register supplies stride zero and is illegal because the row stride must be at least ValidCol."},"legality":["MSCATTER is selected only by BSTART.MSCATTER function 5 in the TLSU selector space; it has no standalone opcode.","Exactly one terminating Local B.IOT supplies DataTile and IndexTile with no destination or TSize. B.IOS and additional Tile bindings are not accepted.","DataTile and IndexTile must be allocated and fully defined. DataTile DataType must equal the BSTART transfer DataType. IndexTile must use S32, U32, S64, or U64, and every element is interpreted as a signed or unsigned logical linear element index.","DataTile physical Col equals resolved LB2. Both sources have resolved ValidRow x ValidCol and selected Layout; IndexTile may use a different physical shape outside that valid rectangle.","Packed four-bit transfer DataTypes E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 are rejected because the block carries no nibble selector.","B.IOT PE_MASK=0000 is a strict no-op before schema, GPR, source, dimension, address, permission, event, or memory checks.","B.DATR applicability allows only Layout.","The B.IOR row stride is nonzero and no smaller than ValidCol; an invalid stride rejects before address probes or effects."],"memory_effects":["For every valid coordinate, store the corresponding DataTile element to BaseGPR plus ((floor(index / ValidCol) * row_stride_elements) + (index mod ValidCol)) times the transfer element size.","Only ValidRow x ValidCol is written; source physical elements outside the valid rectangle have no memory effect.","All valid-lane addresses are preflighted before stores. Duplicate or overlapping target addresses have an implementation-defined final winner."],"operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"per-PE private-GPR GM row stride in elements"},{"field":"source0","role":"source data"},{"field":"source1","role":"logical linear element indices"}],"ordering":["No lane or inter-PE issue order is architecturally guaranteed.","B.CATR.atomic=1 makes the complete block memory effect non-interleavable but does not define an internal lane order or a duplicate-address winner.","Base, stride, dimensions, and all enabled indices are snapshotted before complete address preflight."],"standalone_opcode":false,"state_effects":["Source Tile descriptors and payloads persist unchanged after success or rejection.","On success only memory and memory-event state change; MSCATTER allocates no destination Tile."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MSCATTER","mnemonic":"MSCATTER","summary":"Scatter the valid source region to GM using signed or unsigned logical linear element indices.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MSCATTER-BYTE-DISPLACEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MSCATTER MUST accept non-packed B8-NP, B16, B32, or B64 transfer data with
// S32, U32, S64, or U64 IndexTile elements. It MUST interpret each index as a
// full-width logical linear element index, move raw carrier bits without numeric-validity
// rejection, preflight every valid lane before its first store, and leave
// source descriptors unchanged. Packed transfer types MUST reject.
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

pure func InstructionContractUsesLogicalElementIndices_MSCATTER()
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
