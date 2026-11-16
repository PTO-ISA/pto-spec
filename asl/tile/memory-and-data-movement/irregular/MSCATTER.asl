// PTO-INSTRUCTION: {"assembly":["MSCATTER <bundle operands>"],"block":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[77],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"source0"},{"operand":"source1"}],"command_mnemonic":"BSTART.MSCATTER","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":5,"legality_handler":"TileOperandsLegal_MSCATTER","name":"MSCATTER","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source"},{"field":"source1","role":"byte-displacement-indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER","semantic_summary":"scatter using explicit byte displacements.","state_effects":["operand:address:base-address","operand:source0:source","operand:source1:byte-displacement-indices"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, MinIndexGPR, MaxIndexGPR, ->zero (optional indexed range descriptor; RegSrc1=RegSrc2=zero preserves the legacy absent form)","BSTOP","When a GPR ExecutionMask is combined with a descriptor: B.IOR MaskLoGPR, MaskHiGPR, zero, ->zero, ExecMaskPresent (final record only; one/two mask words as required)"],"canonical_assembly":["MSCATTER <bundle operands>"],"defaults":["B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.","IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed.","For indexed TLSU, RegSrc0 is the unsigned per-PE GM base. When the first B.IOR is not a legacy GPR ExecutionMask record, the selector pair (RegSrc1, RegSrc2)=(0,0) means no range descriptor; any other pair selects full-width S64 MinIndexGPR and MaxIndexGPR relative byte displacements. The one-record ExecMaskPresent form keeps its legacy Base-plus-mask meaning. A descriptor with a GPR ExecutionMask uses an unflagged Base/Min/Max first record and one final contiguous mask record with ExecMaskPresent=1."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP","B.IOR BaseGPR, MinIndexGPR, MaxIndexGPR, ->zero (optional indexed range descriptor; RegSrc1=RegSrc2=zero preserves the legacy absent form)"],"exceptions":["Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero."},"legality":["Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.","ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.","Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.","B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","A present range descriptor supplies signed 64-bit relative byte-displacement bounds, read from the current participating PE. The current request faults with Fault_TileLegality when MinIndex > MaxIndex, before its indexed memory or Tile destination effects; committed peer effects remain. Software certifies that every participating active indexed access start byte is within the inclusive bounds and that [Base+Min, Base+Max+AccessBytes) is nonwrapping in the 64-bit GM address domain; hardware does not validate each IndexTile value against the certificate."],"memory_effects":["Each indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.","All valid addresses are preflighted before the first architectural effect."],"operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source data"},{"field":"source1","role":"byte-displacement indices"}],"ordering":["Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.","The optional descriptor is a conservative indexed access-set summary only. Absence or incomparable/possibly aliased translated ranges retain conservative dependence handling; interval disjointness may remove only conflict edges permitted by the existing PTO memory model and never weakens independent ordering constraints."],"standalone_opcode":false,"state_effects":["Source Tile descriptors and payloads persist unchanged after success or rejection.","On success only memory and memory-event state change; MSCATTER allocates no destination Tile."]},"depends_on":["PTO-ARCH-MEMORY-MODEL-ORDERING","PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA","PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING","PTO-TILE-MODEL-MEMORY-ADDRESSING"],"engine":"TLSU","id":"PTO-TILE-MSCATTER","mnemonic":"MSCATTER","summary":"scatter using explicit byte displacements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MSCATTER-BYTE-DISPLACEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MSCATTER MUST accept B8-NP, B16, B32, B64, and packed four-bit transfer data with
// S32, U32, S64, or U64 IndexTile elements. It MUST interpret each index as a
// full-width byte displacement, move raw carrier bits without numeric-validity
// rejection, preflight every valid lane before its first store, and leave
// source descriptors unchanged. Packed four-bit transfers form one byte from
// two adjacent logical nibbles, with the low nibble first.
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

pure func InstructionContractUsesByteDisplacements_MSCATTER()
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
