// PTO-INSTRUCTION: {"assembly":["MGATHER <bundle operands>"],"block":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[76],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"address"},{"operand":"source0"},{"runtime":"CurrentBundlePadValue"}],"command_mnemonic":"BSTART.MGATHER","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"MGATHER","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":4,"legality_handler":"TileOperandsLegal_MGATHER","name":"MGATHER","operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"indices"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"MGATHER","state_effects":["operand:destination0:destination","operand:address:base-address","operand:source0:byte-displacement-indices","runtime:CurrentBundlePadValue:physical-padding"],"semantic_summary":"gather using explicit byte displacements."}],"classification":["memory-and-data-movement","irregular"],"contract":{"block_composition":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["MGATHER <bundle operands>"],"defaults":["B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies the independent physical Col; canonical macros require Col and default ValidCol to Col. Physical B.DIM omission defaults remain owned by the B.DIM contract.","IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero."},"legality":["Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.","ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.","Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.","B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero."],"memory_effects":["Each indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.","All valid addresses are preflighted before the first architectural effect."],"operands":[{"field":"destination0","role":"destination"},{"field":"address","role":"base-address"},{"field":"source0","role":"byte-displacement indices"}],"ordering":["Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged."],"standalone_opcode":false,"state_effects":["The complete physical destination region is initialized to PadValue before active valid results are published.","On success the full physical destination region is defined; a failing attempt publishes no destination."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-MGATHER","mnemonic":"MGATHER","summary":"gather using explicit byte displacements.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-MGATHER-BYTE-DISPLACEMENT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// MGATHER MUST accept B8-NP, B16, B32, B64, and packed four-bit transfer data with
// S32, U32, S64, or U64 IndexTile elements. It MUST interpret each index as a
// full-width byte displacement, move raw carrier bits without numeric-validity
// rejection, probe the complete valid region before effects, and define the
// full physical destination using B.DATR padding outside the valid region.
// Packed four-bit transfers MUST map one index to one byte and two adjacent
// logical nibbles, with the low nibble first.
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

pure func InstructionContractUsesByteDisplacements_MGATHER()
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
