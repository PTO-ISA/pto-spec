// PTO-INSTRUCTION: {"assembly":["MSCATTER_MASK <bundle operands>"],"block":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[79],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"}],"command_mnemonic":"BSTART.MSCATTER.MASK","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"MSCATTER_MASK","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":7,"legality_handler":"TileOperandsLegal_MSCATTER_MASK","name":"MSCATTER_MASK","operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source"},{"field":"source1","role":"byte-displacement-indices"},{"field":"source2","role":"exact-predicate-mask"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MSCATTER_MASK","state_effects":["operand:address:base-address","operand:source0:source","operand:source1:byte-displacement-indices","operand:source2:exact-predicate-mask"],"semantic_summary":"Masked scatter using explicit byte displacements."}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["MSCATTER_MASK <bundle operands>"],"defaults":["B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.","IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero."},"legality":["PredicateTile is an ordinary Local U8 predicate carrier with one 0x00 or 0x01 element per indexed transaction; every other value rejects before effects.","PredicateTile valid shape equals IndexTile valid shape and its producer DataType does not constrain the transfer DataType.","Packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and one predicate controls the complete byte pair.","ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.","Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.","B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero."],"memory_effects":["Each enabled indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.","A false predicate performs no address generation, translation, permission check, memory probe, event, access, or data-access fault."],"operands":[{"field":"address","role":"base-address"},{"field":"source0","role":"source data"},{"field":"source1","role":"byte-displacement indices"},{"field":"source2","role":"U8 PredicateTile"}],"ordering":["Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged."],"standalone_opcode":false,"state_effects":["All three source descriptors and payloads persist unchanged after success or rejection.","On success only enabled-lane memory and event state changes; MSCATTER_MASK allocates no destination Tile."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MSCATTER-MASK","mnemonic":"MSCATTER_MASK","summary":"Masked scatter using explicit byte displacements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MSCATTER-MASK-PREDICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// PredicateTile MUST use one ordinary Local U8 element per transaction; every
// element MUST be 0x00 or 0x01. A zero value MUST suppress address generation, translation,
// permission checks, stores, and events; a one bit MUST enable the
// corresponding signed-or-unsigned byte-displacement store.
// NDF-END: PTO-MSCATTER-MASK-PREDICATE-001
// NDF-BEGIN: PTO-MSCATTER-MASK-DUPLICATE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Duplicate enabled addresses MUST have an implementation-defined winner.
// B.CATR.atomic MUST NOT impose an internal enabled-lane order; it only makes
// the complete block effect non-interleavable.
// NDF-END: PTO-MSCATTER-MASK-DUPLICATE-001
// NDF-BEGIN: PTO-MSCATTER-MASK-TYPE-002
// ndf: kind=contract level=L1 layer=tile status=accepted
// MSCATTER_MASK MUST accept B8-NP, B16, B32, B64, and packed four-bit transfer
// data with S32, U32, S64, or U64 byte displacements. Packed four-bit data MUST
// use two adjacent logical nibbles per indexed byte and one predicate per pair.
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
