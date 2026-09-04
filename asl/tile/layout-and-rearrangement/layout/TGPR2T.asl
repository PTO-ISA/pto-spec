// PTO-INSTRUCTION: {"assembly":["TGPR2T <bundle operands>"],"block":["BSTART.SFU TGPR2T, U8","B.DATR PadValueOrByteId, RMode (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow","B.IOR GPR0, GPR1, GPR2","B.IOR GPR3","B.IOT mask=PE_MASK, <last>, ->destination<TSize>","BSTOP"],"catalog_indices":[99],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"},{"operand":"source1"},{"operand":"source2"},{"operand":"source3"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","RMode"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"TGPR2T","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":30,"legality_handler":"TileOperandsLegal_TGPR2T","mode":3,"name":"TGPR2T","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source0"},{"field":"source1","role":"source1"},{"field":"source2","role":"source2"},{"field":"source3","role":"source3"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x07E","semantic_handler":"TGPR2T","state_effects":["operand:destination0:CUBE U8 destination","operand:source0:ordered source-only GPR0","operand:source1:ordered source-only GPR1","operand:source2:ordered source-only GPR2","operand:source3:ordered source-only GPR3"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.SFU TGPR2T, U8","B.DATR PadValueOrByteId, RMode (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow","B.IOR GPR0, GPR1, GPR2","B.IOR GPR3","B.IOT mask=PE_MASK, <last>, ->destination<TSize>","BSTOP"],"canonical_assembly":["TGPR2T <bundle operands>"],"defaults":["Omitted B.DATR selects Zero padding and ByteOffset0.","LB1/LB0=32/4 selects CUBE_M32; LB1/LB0=16/8 selects CUBE_M16. Both dimensions are mandatory and LB2 is absent."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TGPR2T, U8; B.DATR PadValueOrByteId, RMode; B.DIM LB0=ValidCol; B.DIM LB1=ValidRow; B.IOR a0, a1, a2; B.IOR a3; B.IOT mask=1111, <last>, ->T0<TSize>; BSTOP"],"exceptions":["RMode[17] must be zero. PadValue accepts only Zero or Max; Min and Null reject before effects.","Exactly two immediately contiguous source-only B.IOR records split 3+1 are required, followed by one destination B.IOT. Missing dimensions, an intervening command, wrong order/split, GPR destination, or surplus record rejects before effects."],"field_contracts":{},"field_zero_meanings":{"PadValueOrByteId":"Zero padding","RMode":"ByteOffset0; RMode[17] reserved-zero"},"legality":["TGPR2T uses TEPL Mode 3 Function 30 (0x07E) with U8 operation type.","Exact dimensions 32x4 select an ordinary numeric CUBE_M32 destination and 16x8 select CUBE_M16; LB2 is absent and the encoded TSize must cover the complete descriptor.","Four ordered source-only 64-bit GPRs are supplied by exactly two contiguous B.IOR records with arity 3+1; selectors are absolute GPR0..GPR23.","Zero and Max are the only padding values. PE_MASK=0000 is a strict no-op before schema, GPR reads, allocation, or effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"ordinary numeric U8 CUBE destination"},{"field":"source0","role":"ordered source-only GPR0"},{"field":"source1","role":"ordered source-only GPR1"},{"field":"source2","role":"ordered source-only GPR2"},{"field":"source3","role":"ordered source-only GPR3"}],"ordering":["All four GPR sources and PE mask are snapshotted before destination publication.","No old destination payload is read; successful publication is atomic."],"standalone_opcode":false,"state_effects":["Pack M32 rows as eight predicate bits into one selected U8 byte; pack M16 rows as sixteen bits into two selected U8 bytes.","PadValue is independent of ByteOffset; the operation does not change GPRs or status."]},"depends_on":["PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"],"engine":"SFU","id":"PTO-TILE-TGPR2T","mnemonic":"TGPR2T","summary":"Re-encode four GPR predicate planes into an ordinary CUBE U8 Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TGPR2T-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TGPR2T MUST consume exact LB1/LB0 shape 32/4 or 16/8, exactly two
// immediately contiguous source-only B.IOR records with arity 3+1, and one
// new destination B.IOT. It MUST transpose four complete 64-bit GPR predicate
// sub-plane carriers into ordinary numeric CUBE U8 storage, accept only Zero
// or Max whole-tile padding, and publish no GPR or numeric-status effect.
// NDF-END: PTO-TGPR2T-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TGPR2T() => TileOperation
begin
    return TileOperation_TGPR2T;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TGPR2T() => TileSemanticHandler
begin
    return TileHandler_TGPR2T;
end;

pure func InstructionContractDataTypeLegal_TGPR2T(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_U8;
end;

readonly func InstructionContractOperandsLegal_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex) => boolean
begin
    return TileOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
end;

func InstructionContractExecute_TGPR2T(
    destination: TileIndex, source0: TileIndex, source1: TileIndex,
    source2: TileIndex, source3: TileIndex)
begin
    assert InstructionContractOperandsLegal_TGPR2T(
        destination, source0, source1, source2, source3);
    TGPR2T(destination, source0, source1, source2, source3);
end;
// DOC-END: operation
