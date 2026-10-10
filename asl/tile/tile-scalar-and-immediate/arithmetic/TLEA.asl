// PTO-INSTRUCTION: {"assembly":["TLEA <bundle operands>"],"block":["BSTART.VEC TLEA, SrcDataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=DstCol (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->ByteOffsetTile<TSize>","B.IOR ElementBitsGPR, zero, zero, ->zero","BSTOP"],"catalog_indices":[118],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"scalar0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"TLEA","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":14,"legality_handler":"TileOperandsLegal_TLEA","mode":1,"name":"TLEA","operands":[{"field":"destination0","role":"new Local S64/U64 byte-offset destination"},{"field":"source0","role":"persistent Local S32/U32/S64/U64 element indices"},{"field":"scalar0","role":"per-PE element width in bits"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x02E","semantic_handler":"TLEA","state_effects":["operand:destination0:new-local-byte-offset-destination","operand:source0:persistent-local-element-indices","operand:scalar0:element-width-bits","runtime:CurrentBundlePadValue:numeric-padding"]}],"classification":["tile-scalar-and-immediate","arithmetic"],"contract":{"block_composition":["BSTART.VEC TLEA, SrcDataType","B.DATR PadValue, Layout (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional)","B.DIM LB2=DstCol (optional)","B.IOT IndexTile, mask=PE_MASK, <last>, ->ByteOffsetTile<TSize>","B.IOR ElementBitsGPR, zero, zero, ->zero","BSTOP"],"canonical_assembly":["TLEA <bundle operands>"],"defaults":["LB0 is required and supplies ValidCol; omitted LB1 selects one and omitted LB2 selects destination physical Col equal to ValidCol.","B.IOR is required and RegSrc0 supplies element width in bits; there is no implicit width or base address.","Omitted B.DATR selects PadValue=Null and RowMajor; Layout 29/31 select CUBE_M32/CUBE_M16."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.VEC TLEA, S32; B.DIM LB0=ValidCol; B.IOT IndexTile, mask=PE_MASK, <last>, ->ByteOffsetTile<TSize>; B.IOR ElementBitsGPR, zero, zero, ->zero; BSTOP"],"exceptions":["Unsupported index types, element widths, layout, descriptor, schema or logical-shape mismatch rejects before effects; insufficient destination capacity follows Fault_TileAllocation.","No overflow, memory-access or numeric-status fault is introduced."],"field_contracts":{"B.IOR.RegSrc0":{"ref":"PTO-FIELD-BLOCK-GPR-SELECTOR"}},"field_zero_meanings":{"B.IOR.RegSrc0":"The zero register supplies zero, which is an illegal element width for an active block."},"legality":["TEPL Mode 1 Function 14 (selector 0x02E) accepts exactly S32, U32, S64 and U64 source operation/backing types.","The scalar element width is exactly 8, 16, 32 or 64 bits; packed four-bit widths reject.","One terminating Local B.IOT supplies one index source and a renamed destination; B.IOR is required and unused selectors/destination encode zero, subject to explicit ExecutionMask binding extensions.","Source and destination have matching logical valid shape and RowMajor/CUBE_M32 layout, with independent physical capacity and geometry; Shared and CUBE_N8 reject.","B.DATR accepts padding/layout and existing applicable ExecutionMask controls; numeric conversion controls are not applicable.","PE_MASK=0000 is a strict no-op before reads, allocation and faults.","Local CUBE_M32 S64/U64 output uses the issue #371 double-CELL mapping; RowMajor is also legal and CUBE_M16 b64 output is not assigned."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local S64/U64 byte-offset destination"},{"field":"source0","role":"persistent Local S32/U32/S64/U64 element indices"},{"field":"scalar0","role":"per-PE element width in bits"}],"ordering":["Complete legality/allocation preflight and source snapshots precede atomic destination publication."],"standalone_opcode":false,"state_effects":["Signed inputs sign-extend to S64 and unsigned inputs zero-extend to U64 before multiplication by element_bits/8; retain the low 64 bits.","TLEA generates byte offsets only, without BaseGPR addition, memory events or numeric-status updates.","Inactive Local CUBE ExecutionMask coordinates follow existing MERGE/ZERO without source reads; direct S64/U64 aliasing reads old source payloads."]},"depends_on":["PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING","PTO-TILE-MODEL-EXECUTION-LEA","PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS"],"engine":"VEC","id":"PTO-TILE-TLEA","mnemonic":"TLEA","summary":"Extend logical element indices to 64 bits and explicitly scale them to byte offsets.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TLEA-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TLEA MUST select TEPL Mode 1 Function 14 and consume one Local numeric
// IndexTile of exactly S32, U32, S64 or U64 and one required per-PE private-GPR
// element width of exactly 8, 16, 32 or 64 bits. The selected source operation
// type MUST equal its backing type. Signed indices MUST sign-extend to S64 and
// unsigned indices MUST zero-extend to U64 BEFORE scaling by element_bits/8;
// the result MUST retain the low 64 bits without saturation or overflow fault.
// The destination MUST use corresponding S64 or U64 with the same logical
// valid shape and layout but independent physical geometry and capacity.
// TLEA MUST produce only byte offsets; it MUST NOT add BaseGPR, access memory,
// generate memory events or update numeric status. Packed four-bit, Shared
// and CUBE_N8 forms MUST reject. Local RowMajor and CUBE_M32 forms
// MUST preflight all schema, descriptor, source and capacity legality before
// snapshotting the source and atomically publishing the destination.
// B.IOR MUST bind the width in RegSrc0 with unused fields zero, apart from the
// explicit existing ExecutionMask extension. Inactive Local CUBE coordinates
// MUST use the existing MERGE/ZERO contract without source reads. PE_MASK=0000
// MUST remain a strict no-op. Direct S64/U64 aliasing MUST read the old source.
// Indexed TLSU MUST retain its separately owned byte-displacement semantics.
// NDF-END: PTO-TLEA-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TLEA() => TileOperation
begin
    return TileOperation_TLEA;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TLEA(data_type: TileDataType)
    => boolean
begin
    return TileLEAIndexDataTypeLegal(data_type);
end;

readonly func InstructionContractHandler_TLEA() => TileSemanticHandler
begin
    return TileHandler_TLEA;
end;

func InstructionContractExecute_TLEA(
    destination: TileIndex, source: TileIndex, element_bits: Word)
begin
    assert TileOperandsLegal_TLEA(destination, source, element_bits);
    TLEA(destination, source, element_bits);
end;
// DOC-END: operation
