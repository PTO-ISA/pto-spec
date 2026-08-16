// PTO-INSTRUCTION: {"assembly":["BSTART.MSCATTER.MASK DataType"],"block":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[25],"catalog_records":[{"asm":"BSTART.MSCATTER.MASK DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00711181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_mscatter_mask_32_2a33eed646f7","length_bits":32,"mnemonic":"BSTART.MSCATTER.MASK","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Begins a predicate-masked TLSU byte-displacement scatter block.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.MSCATTER.MASK DataType","B.DATR Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT DataTile, IndexTile, mask=PE_MASK","B.IOT MaskTile, mask=PE_MASK, <last>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.MSCATTER.MASK DataType"],"defaults":["DataType is always encoded and selects the memory transfer type.","The completed schema requires explicit B.IOR and LB0. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR selects NORM layout."],"encoding_class":"standalone-encoded","examples":["BSTART.MSCATTER.MASK DataType; B.DATR Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT DataTile, IndexTile, mask=PE_MASK; B.IOT MaskTile, mask=PE_MASK, <last>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.","Malformed composition, invalid predicate values, type/shape/layout mismatch, packed transfer types, or enabled-lane access faults reject before any store or event."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["bstart_mscatter_mask_32_2a33eed646f7.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.","Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because no nibble selector is encoded.","The body must complete the exact two-B.IOT schema documented by PTO-TILE-MSCATTER-MASK; no B.IOS or destination is accepted."],"memory_effects":["The start itself performs no memory access. BSTOP or the next BSTART commits only exact-one lanes after complete enabled-lane preflight."],"operands":[{"field":"DataType","role":"memory transfer element type selector"}],"ordering":["The start defines no ordering. B.CATR attributes apply when the completed block commits."],"standalone_opcode":true,"state_effects":["Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 7 with encoded DataType.","No Tile is allocated and no source is consumed by the start instruction."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-MSCATTER-MASK","mnemonic":"BSTART.MSCATTER.MASK","summary":"Begins a predicate-masked TLSU byte-displacement scatter block.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-MSCATTER-MASK-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A participating BSTART.MSCATTER.MASK block MUST contain explicit B.IOR and
// LB0 plus exactly two Local B.IOT records: DataTile with IndexTile, followed
// by MaskTile with the sole last marker. Neither record has a destination.
// NDF-END: PTO-BSTART-MSCATTER-MASK-SCHEMA-001
// DOC-BEGIN: decode
readonly func InstructionContractMatches_BSTART_MSCATTER_MASK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_mscatter_mask_32_2a33eed646f7);
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_BSTART_MSCATTER_MASK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractStartedTileOperation_BSTART_MSCATTER_MASK()
    => TileOperation
begin
    return TileOperation_MSCATTER_MASK;
end;

pure func InstructionContractStartsTileBundle_BSTART_MSCATTER_MASK()
    => boolean
begin
    return TRUE;
end;
// DOC-END: operation
