// PTO-INSTRUCTION: {"assembly":["BSTART.MSCATTER DataType"],"block":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[26],"catalog_records":[{"asm":"BSTART.MSCATTER DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00511181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_mscatter_32_0f0ba08bd798","length_bits":32,"mnemonic":"BSTART.MSCATTER","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"scatter using explicit byte displacements.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.MSCATTER DataType"],"defaults":["B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.","IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed."],"encoding_class":"standalone-encoded","examples":["BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero."},"legality":["Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.","ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.","Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.","B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero."],"memory_effects":["Each indexed transaction stores one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.","All valid addresses are preflighted before the first architectural effect."],"operands":[{"field":"DataType","role":"memory transfer element type selector"},{"field":"B.IOR.RegSrc0","role":"per-PE private-GPR GM base address"},{"field":"B.IOR.RegSrc1","role":"per-PE private-GPR zero selector"}],"ordering":["Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged."],"standalone_opcode":true,"state_effects":["Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 5 with the encoded transfer DataType.","No Tile is allocated and no source is consumed by the start instruction."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"],"id":"PTO-BLOCK-BSTART-MSCATTER","mnemonic":"BSTART.MSCATTER","summary":"scatter using explicit byte displacements.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-MSCATTER-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A participating BSTART.MSCATTER block MUST contain explicit B.IOR, LB0,
// and exactly one terminating Local B.IOT carrying DataTile and IndexTile with
// no destination. Omitted LB1, LB2, and B.DATR MUST use MSCATTER defaults.
// B.IOR RegSrc0 MUST supply the GM base; RegSrc1, RegSrc2, and RegDst MUST
// encode zero.
// NDF-END: PTO-BSTART-MSCATTER-SCHEMA-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_MSCATTER(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_32_0f0ba08bd798);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_MSCATTER() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER()
    => TileOperation
begin
    return TileOperation_MSCATTER;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
