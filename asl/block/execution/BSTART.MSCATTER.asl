// PTO-INSTRUCTION: {"assembly":["BSTART.MSCATTER DataType"],"block":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[26],"catalog_records":[{"asm":"BSTART.MSCATTER DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00511181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_mscatter_32_0f0ba08bd798","length_bits":32,"mnemonic":"BSTART.MSCATTER","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Begins a strided indexed TLSU scatter block.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.MSCATTER DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK, <last>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.MSCATTER DataType"],"defaults":["DataType is always encoded and selects the memory transfer type.","The completed schema requires explicit B.IOR: RegSrc0 supplies the per-PE GM base address and RegSrc1 supplies a nonzero GM row stride in elements no smaller than ValidCol. RegSrc2 and RegDst remain zero. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR uses the operation defaults."],"encoding_class":"standalone-encoded","examples":["BSTART.MSCATTER DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK, <last>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.","Malformed composition, source/type/shape/layout mismatch, packed transfer types, or access faults reject the complete block before any store or event effect."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["bstart_mscatter_32_0f0ba08bd798.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.","Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because MSCATTER carries no nibble selector.","The body must complete the exact MSCATTER schema documented by PTO-TILE-MSCATTER; no B.IOS or destination is accepted.","B.IOR RegSrc0 supplies the per-PE GM base and RegSrc1 supplies the GM row stride in elements. RegSrc1 must be at least ValidCol; RegSrc2 and RegDst must be zero."],"memory_effects":["The start itself performs no memory access. BSTOP or the next BSTART commits the completed strided indexed scatter only after full preflight."],"operands":[{"field":"DataType","role":"memory transfer element type selector"},{"field":"B.IOR.RegSrc0","role":"per-PE private-GPR GM base address"},{"field":"B.IOR.RegSrc1","role":"per-PE private-GPR GM row stride in elements"}],"ordering":["The start defines no ordering. B.CATR attributes apply when the completed block commits."],"standalone_opcode":true,"state_effects":["Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 5 with the encoded transfer DataType.","No Tile is allocated and no source is consumed by the start instruction."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-MSCATTER","mnemonic":"BSTART.MSCATTER","summary":"Begins a strided indexed TLSU scatter block.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-MSCATTER-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A participating BSTART.MSCATTER block MUST contain explicit B.IOR, LB0,
// and exactly one terminating Local B.IOT carrying DataTile and IndexTile with
// no destination. Omitted LB1, LB2, and B.DATR MUST use MSCATTER defaults.
// B.IOR RegSrc0 MUST supply the GM base and RegSrc1 MUST supply the GM row
// stride in elements; RegSrc2 and RegDst MUST encode zero.
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
