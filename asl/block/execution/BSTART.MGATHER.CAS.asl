// PTO-INSTRUCTION: {"assembly":["BSTART.MGATHER.CAS DataType"],"block":["BSTART.MGATHER.CAS DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, ExpectedTile, mask=PE_MASK","B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"catalog_indices":[23],"catalog_records":[{"asm":"BSTART.MGATHER.CAS DataType","constraints":[{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}],"encoding":[{"index":0,"mask":"0x07ffffff","match":"0x00811181","width_bits":32}],"encoding_kind":"L32","fields":[{"name":"DataType","pieces":[{"instruction_lsb":27,"value_lsb":0,"width":5}],"signedness":"encoding-defined","width":5}],"form_id":"bstart_mgather_cas_32_fd8c8a3b720a","length_bits":32,"mnemonic":"BSTART.MGATHER.CAS","semantic_family":"CMD","semantic_group":"Bundle Split","semantic_handler":"ExecuteBundleStart","semantic_summary":"Begins an atomic compare-and-swap strided indexed TLSU gather block.","status":"accepted"}],"classification":["execution"],"contract":{"block_composition":["BSTART.MGATHER.CAS DataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=Col (optional)","B.IOT IndexTile, ExpectedTile, mask=PE_MASK","B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>","B.IOR BaseGPR, StrideGPR, zero, ->zero","BSTOP"],"canonical_assembly":["BSTART.MGATHER.CAS DataType"],"defaults":["DataType is always encoded and selects the transfer, comparison, replacement, and destination element type.","The completed schema requires explicit B.IOR: RegSrc0 supplies the per-PE GM base address and RegSrc1 supplies a nonzero GM row stride in elements no smaller than ValidCol. RegSrc2 and RegDst remain zero. Omitted LB1 defaults to one, omitted LB2 defaults to LB0, and omitted B.DATR uses the operation defaults."],"encoding_class":"standalone-encoded","examples":["BSTART.MGATHER.CAS DataType; B.DATR PadValue, Layout (optional); B.DIM LB0=ValidCol; B.DIM LB1=ValidRow (optional); B.DIM LB2=Col (optional); B.IOT IndexTile, ExpectedTile, mask=PE_MASK; B.IOT ReplacementTile, mask=PE_MASK, <last>, ->DstTile<TSize>; B.IOR BaseGPR, StrideGPR, zero, ->zero; BSTOP"],"exceptions":["Reserved DataType encodings raise Fault_IllegalInstruction before architectural effects.","At bundle completion, malformed two-command B.IOT composition, missing B.IOR or LB0, packed transfer types, non-integer indices, mismatched source type or shape, invalid dimensions, or any read/write access fault is rejected before destination allocation, atomic events, or memory writes."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"DataType":"Encoded zero selects FP64."},"legality":["bstart_mgather_cas_32_fd8c8a3b720a.DataType accepts only 0..14, 16..20, and 24..28 at decode; all other encodings are reserved.","Indexed TLSU transfer additionally rejects E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2 because MGATHER.CAS carries no nibble selector.","The body must complete the exact two-B.IOT Local schema documented by PTO-TILE-MGATHER-CAS. B.IOS and extra bindings are not accepted.","PE_MASK=0000 is a strict no-op before all schema, GPR, source, dimension, allocation, address, and fault checks.","B.IOR RegSrc0 supplies the per-PE GM base and RegSrc1 supplies the GM row stride in elements. RegSrc1 must be at least ValidCol; RegSrc2 and RegDst must be zero."],"memory_effects":["The start itself performs no memory access. BSTOP or the next BSTART performs the fully preflighted per-lane atomic compare-and-swap sequence.","Duplicate-address lanes are legal and serialize in an implementation-defined order; each lane still supplies one atomic event."],"operands":[{"field":"DataType","role":"transfer, comparison, replacement, and destination element type"},{"field":"B.IOR.RegSrc0","role":"per-PE private-GPR GM base address"},{"field":"B.IOR.RegSrc1","role":"per-PE private-GPR GM row stride in elements"}],"ordering":["Each valid lane is one atomic read-modify-write under the block aq/rl attributes. No fixed order is defined between duplicate-address lanes or between PEs."],"standalone_opcode":true,"state_effects":["Closes any preceding block, initializes a TileMemory descriptor, and selects TLSU function 8 with the encoded transfer DataType.","No destination is allocated until the completed block passes schema, source, dimension, and complete access preflight."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-PROFILE-ENCODING"],"id":"PTO-BLOCK-BSTART-MGATHER-CAS","mnemonic":"BSTART.MGATHER.CAS","summary":"Begins an atomic compare-and-swap strided indexed TLSU gather block.","surface":"block"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-BSTART-MGATHER-CAS-SCHEMA-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A participating BSTART.MGATHER.CAS block MUST contain explicit B.IOR, LB0,
// one non-terminating Local B.IOT carrying IndexTile and ExpectedTile, and one
// terminating Local B.IOT carrying ReplacementTile and destination. Omitted
// LB1, LB2, and B.DATR MUST use the MGATHER.CAS defaults.
// B.IOR RegSrc0 MUST supply the GM base and RegSrc1 MUST supply the GM row
// stride in elements; RegSrc2 and RegDst MUST encode zero.
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
