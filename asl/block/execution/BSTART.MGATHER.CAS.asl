// PTO-INSTRUCTION: {"assembly":["BSTART.MGATHER.CAS DataType"],"block":["BSTART.MGATHER.CAS DataType","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1)","B.DIM LB2=ValidCol","B.DATR PadValue, Layout (optional)","B.IOT IndexTile, ExpectedTile, mask=PE_MASK","B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[23],"catalog_records":[{"asm":"BSTART.MGATHER.CAS DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00811181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_mgather_cas_32_fd8c8a3b720a","length_bits":32,"mnemonic":"BSTART.MGATHER.CAS","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"atomic compare-and-swap gather using explicit byte displacements.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.MGATHER.CAS DataType","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1)","B.DIM LB2=ValidCol","B.DATR PadValue, Layout (optional)","B.IOT IndexTile, ExpectedTile, mask=PE_MASK","B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.MGATHER.CAS DataType"],"defaults":["B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.","IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed."],"encoding_class":"standalone-encoded","examples":["BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero."},"legality":["Only U16, U32, and U64 transfer DataTypes are accepted; packed four-bit and every other existing unsupported atomic DataType remain illegal.","Index, Expected, Replacement, and destination have equal logical valid shape and layout class.","ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.","Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.","B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero."],"memory_effects":["Each valid coordinate performs one atomic compare-and-swap at BaseGPR plus the sign- or zero-extended byte displacement.","All read/write probes complete before the first atomic effect; observed old values publish in the destination and non-valid physical elements contain PadValue."],"operands":[{"field":"DataType","role":"transfer, comparison, replacement, and destination element type"},{"field":"B.IOR.RegSrc0","role":"per-PE private-GPR GM base address"},{"field":"B.IOR.RegSrc1","role":"per-PE private-GPR zero selector"}],"ordering":["Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged."],"standalone_opcode":true,"state_effects":["The complete physical destination region is initialized to PadValue before active valid results are published.","On success the full physical destination region is defined; a failing attempt publishes no destination."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-MGATHER-CAS","mnemonic":"BSTART.MGATHER.CAS","summary":"atomic compare-and-swap gather using explicit byte displacements.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-MGATHER-CAS-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A participating BSTART.MGATHER.CAS block MUST contain explicit B.IOR, LB0,
// one non-terminating Local B.IOT carrying IndexTile and ExpectedTile, and one
// terminating Local B.IOT carrying ReplacementTile and destination. Omitted
// LB1, LB2, and B.DATR MUST use the MGATHER.CAS defaults.
// B.IOR RegSrc0 MUST supply the GM base; RegSrc1, RegSrc2, and RegDst MUST
// encode zero.
// NDF-END: PTO-BSTART-MGATHER-CAS-SCHEMA-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_MGATHER_CAS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_cas_32_fd8c8a3b720a);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_MGATHER_CAS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_CAS()
    => TileOperation
begin
    return TileOperation_MGATHER_CAS;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_CAS()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
