// PTO-INSTRUCTION: {"assembly":["BSTART.MGATHER DataType"],"block":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[22],"catalog_records":[{"asm":"BSTART.MGATHER DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00411181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_mgather_32_c9defbf18276","length_bits":32,"mnemonic":"BSTART.MGATHER","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Begins a TLSU byte-displacement gather block and selects its transfer DataType.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.MGATHER DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.MGATHER DataType"],"defaults":["DataType is always encoded; its accepted values select the transfer element type and reserved encodings are rejected.","The completed MGATHER schema requires explicit B.IOR and LB0. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR selects Null padding with NORM layout."],"encoding_class":"standalone-encoded","examples":["BSTART.MGATHER DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.","At bundle completion, malformed MGATHER composition, packed four-bit transfer types, non-integer indices, invalid dimensions, or access faults are rejected before any destination or partial memory-event effect."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["bstart_mgather_32_c9defbf18276.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.","Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 before allocation because MGATHER carries no nibble selector.","The body must complete the exact MGATHER schema documented by PTO-TILE-MGATHER; no B.IOS or additional Tile source is accepted."],"memory_effects":["The start itself performs no memory access. BSTOP or the next BSTART commits the completed byte-displacement gather atomically after full preflight."],"operands":[{"field":"DataType","role":"tile element data type selector"}],"ordering":["none"],"standalone_opcode":true,"state_effects":["Closes any preceding block, initializes a new TileMemory descriptor, and selects TLSU function 4 with the encoded transfer DataType.","No destination is allocated until the completed block passes schema, dimension, source, and access checks."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-MGATHER","mnemonic":"BSTART.MGATHER","summary":"Begins a TLSU byte-displacement gather block and selects its transfer DataType.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-MGATHER-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A participating BSTART.MGATHER block MUST contain explicit B.IOR, LB0, and
// exactly one terminating Local B.IOT carrying IndexTile and destination.
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
