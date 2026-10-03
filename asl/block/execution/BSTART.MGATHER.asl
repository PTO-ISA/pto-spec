// PTO-INSTRUCTION: {"assembly":["BSTART.MGATHER DataType"],"block":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[22],"catalog_records":[{"asm":"BSTART.MGATHER DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00411181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_mgather_32_c9defbf18276","length_bits":32,"mnemonic":"BSTART.MGATHER","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"gather using explicit byte displacements.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.MGATHER DataType"],"defaults":["B.IOR is required: RegSrc0 selects the per-PE BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero.","LB0 supplies DataTile ValidCol, LB1 supplies ValidRow, and LB2 supplies DataTile or destination physical Col; omitted LB1 and LB2 default to one and LB0 respectively.","IndexTile entries are S32, U32, S64, or U64 byte displacements and are not scaled or decomposed."],"encoding_class":"standalone-encoded","examples":["BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Malformed bundle schema, nonzero unused B.IOR fields, unsupported datatype or layout, descriptor/shape mismatch, noncanonical predicate values, or an access fault rejects before effects."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The architectural zero register supplies GM base address zero."},"legality":["Non-packed transfer shapes match IndexTile; packed four-bit uses Data.ValidCol == 2 * Index.ValidCol and rejects incomplete pairs.","ROWMAJOR, CUBE_M16, and CUBE_M32 are accepted; CUBE_N8 is rejected.","Participating Local Tiles share the layout class and logical coordinates while retaining independent DataType, TSize, LB2, physical columns, and capacity.","B.IOR RegSrc0 supplies BaseGPR; RegSrc1, RegSrc2, and RegDst must encode zero."],"memory_effects":["Each indexed transaction loads one transfer element, or one packed byte containing the low then high logical nibble, at BaseGPR plus the byte displacement.","All valid addresses are preflighted before the first architectural effect."],"operands":[{"field":"DataType","role":"tile element data type selector"},{"field":"B.IOR.RegSrc0","role":"per-PE private-GPR GM base address"},{"field":"B.IOR.RegSrc1","role":"per-PE private-GPR zero selector"}],"ordering":["Existing PTO memory ordering and implementation-defined duplicate-address serialization are unchanged."],"standalone_opcode":true,"state_effects":["The complete physical destination region is initialized to PadValue before active valid results are published.","On success the full physical destination region is defined; a failing attempt publishes no destination."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"],"id":"PTO-BLOCK-BSTART-MGATHER","mnemonic":"BSTART.MGATHER","summary":"gather using explicit byte displacements.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-MGATHER-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A participating BSTART.MGATHER block MUST contain explicit B.IOR, LB0, and
// exactly one terminating Local B.IOT carrying IndexTile and destination.
// B.IOR RegSrc0 MUST supply the GM base; RegSrc1, RegSrc2, and RegDst MUST
// encode zero.
// Omitted LB1, LB2, and B.DATR MUST use the MGATHER defaults.
// NDF-END: PTO-BSTART-MGATHER-SCHEMA-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_MGATHER(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_32_c9defbf18276);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_MGATHER() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER()
    => TileOperation
begin
    return TileOperation_MGATHER;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
