// PTO-INSTRUCTION: {"assembly":["MGATHER_MASK <bundle operands>"],"block":["BSTART.MGATHER.MASK DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[78],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.MGATHER.MASK","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER_MASK","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_MGATHER_MASK","name":"MGATHER_MASK","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"},{"field":"source1","role":"mask"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER_MASK","semantic_summary":"Masked gather using explicit byte displacements.","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:byte-displacement-indices","operand:source1:exact-predicate-mask","runtime:CurrentBundlePadValue:inactive-and-physical-padding"]}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MGATHER.MASK DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, MinIndexGPR, MaxIndexGPR, ->zero (optional indexed range descriptor; RegSrc1=RegSrc2=zero preserves the legacy absent form)","BSTOP","When a GPR ExecutionMask is combined with a descriptor: B.IOR MaskLoGPR, MaskHiGPR, zero, ->zero, ExecMaskPresent (final record only; one/two mask words as required)"],"canonical_assembly":["MGATHER_MASK <bundle operands>"],"defaults":["B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.","IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed.","For indexed TLSU, RegSrc0 is the unsigned per-PE GM base. When the first B.IOR is not a legacy GPR ExecutionMask record, the selector pair (RegSrc1, RegSrc2)=(0,0) means no range descriptor; any other pair selects full-width S64 MinIndexGPR and MaxIndexGPR relative byte displacements. The one-record ExecMaskPresent form keeps its legacy Base-plus-mask meaning. A descriptor with a GPR ExecutionMask uses an unflagged Base/Min/Max first record and one final contiguous mask record with ExecMaskPresent=1."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP","B.IOR BaseGPR, MinIndexGPR, MaxIndexGPR, ->zero (optional indexed range descriptor; RegSrc1=RegSrc2=zero preserves the legacy absent form)"],"exceptions":["Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero."},"legality":["PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.","PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.","Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.","ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.","Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.","B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","A present range descriptor supplies signed 64-bit relative byte-displacement bounds, read from the current participating PE. The current request faults with Fault_TileLegality when MinIndex > MaxIndex, before its indexed memory or Tile destination effects; committed peer effects remain. Software certifies that every participating active indexed access start byte is within the inclusive bounds and that [Base+Min, Base+Max+AccessBytes) is nonwrapping in the 64-bit GM address domain; hardware does not validate each IndexTile value against the certificate."],"memory_effects":["Each enabled indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.","A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault and leaves the corresponding destination value(s) at PadValue."],"operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"byte-displacement indices"},{"field":"source1","role":"U8 PredicateTile"}],"ordering":["Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged.","The optional descriptor is a conservative indexed access-set summary only. Absence or incomparable/possibly aliased translated ranges retain conservative dependence handling; interval disjointness may remove only conflict edges permitted by the existing PTO memory model and never weakens independent ordering constraints."],"standalone_opcode":false,"state_effects":["The complete physical destination region is initialized to PadValue before active valid results are published.","On success the full physical destination region is defined; a failing attempt publishes no destination."]},"depends_on":["PTO-ARCH-MEMORY-MODEL-ORDERING","PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA","PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING","PTO-TILE-MODEL-MEMORY-ADDRESSING"],"engine":"TLSU","id":"PTO-TILE-MGATHER-MASK","mnemonic":"MGATHER_MASK","summary":"Masked gather using explicit byte displacements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MGATHER-MASK-PREDICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// PredicateTile MUST use one ordinary Local U8 element per transaction; every
// element MUST be 0x00 or 0x01. A zero value MUST suppress address generation, translation,
// permission checks, memory access, and memory events for that lane and MUST
// select PadValue for the destination. A one bit MUST enable the
// signed-or-unsigned byte-displacement load.
// NDF-END: PTO-MGATHER-MASK-PREDICATE-001
// NDF-BEGIN: PTO-MGATHER-MASK-PUBLICATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MGATHER_MASK MUST preflight all and only enabled addresses before its first
// load effect. On success it MUST publish one fully defined destination whose
// disabled and non-valid physical elements contain the selected pad value.
// NDF-END: PTO-MGATHER-MASK-PUBLICATION-001
// NDF-BEGIN: PTO-MGATHER-MASK-TYPE-002
// ndf: kind=contract level=L1 layer=tile status=accepted
// MGATHER_MASK MUST accept B8-NP, B16, B32, B64, and packed four-bit transfer
// data with S32, U32, S64, or U64 byte displacements. Packed four-bit data MUST
// use two adjacent logical nibbles per indexed byte and one predicate per pair.
// NDF-END: PTO-MGATHER-MASK-TYPE-002
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
