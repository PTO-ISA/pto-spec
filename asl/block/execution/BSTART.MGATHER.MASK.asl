// PTO-INSTRUCTION: {"assembly":["BSTART.MGATHER.MASK DataType"],"block":["BSTART.MGATHER.MASK DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[24],"catalog_records":[{"asm":"BSTART.MGATHER.MASK DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00611181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_mgather_mask_32_5573241cd944","length_bits":32,"mnemonic":"BSTART.MGATHER.MASK","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Begins a predicate-masked strided indexed TLSU gather block.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.MGATHER.MASK DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.MGATHER.MASK DataType"],"defaults":["DataType is always encoded and selects the transfer and destination element type.","The completed schema requires explicit B.IOR: RegSrc0 supplies the per-PE GM base address and RegSrc1 supplies a nonzero GM row stride in elements no smaller than ValidCol. RegSrc2 and RegDst remain zero. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR uses the operation defaults."],"encoding_class":"standalone-encoded","examples":["BSTART.MGATHER.MASK DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, MaskTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.","At bundle completion, malformed B.IOT composition, missing B.IOR or LB0, packed transfer types, non-integer indices, predicate values other than zero or one, source shape or layout mismatch, invalid dimensions, zero or undersized row stride, or any enabled-lane access fault is rejected before destination allocation, memory events, or memory reads."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["bstart_mgather_mask_32_5573241cd944.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.","Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because MGATHER.MASK carries no nibble selector.","The body must complete the exact single-B.IOT Local schema documented by PTO-TILE-MGATHER-MASK. B.IOS and extra bindings are not accepted.","PE_MASK=0000 is a strict no-op before all schema, GPR, source, predicate, dimension, allocation, address, and fault checks.","B.IOR RegSrc0 supplies the per-PE GM base and RegSrc1 supplies the GM row stride in elements. RegSrc1 must be at least ValidCol; RegSrc2 and RegDst must be zero."],"memory_effects":["The start itself performs no memory access. BSTOP or the next BSTART preflights and loads only lanes whose exact predicate value is one.","Disabled lanes perform no memory-side operation and receive PadValue together with every non-valid physical destination coordinate."],"operands":[{"field":"DataType","role":"transfer and destination element type"},{"field":"B.IOR.RegSrc0","role":"per-PE private-GPR GM base address"},{"field":"B.IOR.RegSrc1","role":"per-PE private-GPR GM row stride in elements"}],"ordering":["Enabled loads use the block aq/rl attributes and PTO memory-order domain. No additional lane or inter-PE issue order is defined."],"standalone_opcode":true,"state_effects":["Closes any preceding block, initializes a TileMemory descriptor, and selects TLSU function 6 with the encoded transfer DataType.","No destination is allocated until the completed block passes schema, predicate, source, dimension, and enabled-address preflight."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-MGATHER-MASK","mnemonic":"BSTART.MGATHER.MASK","summary":"Begins a predicate-masked strided indexed TLSU gather block.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-MGATHER-MASK-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A participating BSTART.MGATHER.MASK block MUST contain explicit B.IOR, LB0,
// and exactly one terminating Local B.IOT carrying IndexTile, MaskTile, and
// destination. Omitted LB1, LB2, and B.DATR MUST use the masked-gather defaults.
// B.IOR RegSrc0 MUST supply the GM base and RegSrc1 MUST supply the GM row
// stride in elements; RegSrc2 and RegDst MUST encode zero.
// NDF-END: PTO-BSTART-MGATHER-MASK-SCHEMA-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_MGATHER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mgather_mask_32_5573241cd944);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_MGATHER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MGATHER_MASK()
    => TileOperation
begin
    return TileOperation_MGATHER_MASK;
end;

pure func InstructionContractStartsTileBundle_BSTART_MGATHER_MASK()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
