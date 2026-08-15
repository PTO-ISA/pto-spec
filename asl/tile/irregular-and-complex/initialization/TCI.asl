// PTO-INSTRUCTION: {"assembly":["TCI <bundle operands>"],"block":["BSTART.SFU TCI, S32|S16|U32|U16","B.DATR all-zero (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1; when present must equal 1)","B.DIM LB2=Col (optional, default ValidCol)","B.IOR Start, Direction (optional; omission selects 0 and ascending)","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[73],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"scalar0"},{"operand":"flag0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":[],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TCI","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_TCI","mode":3,"name":"TCI","operands":[{"field":"destination0","role":"new Local S32, S16, U32, or U16 destination"},{"field":"scalar0","role":"typed sequence start"},{"field":"flag0","role":"ascending or descending direction"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x066","semantic_handler":"TCI","state_effects":["operand:destination0:new-local-integer-destination","operand:scalar0:typed-sequence-start","operand:flag0:ascending-or-descending","runtime:TilePad_Null:physical-padding"]}],"classification":["irregular-and-complex","initialization"],"contract":{"block_composition":["BSTART.SFU TCI, S32|S16|U32|U16","B.DATR all-zero (optional)","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (optional, default 1; when present must equal 1)","B.DIM LB2=Col (optional, default ValidCol)","B.IOR Start, Direction (optional; omission selects 0 and ascending)","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TCI <bundle operands>"],"defaults":["LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; an explicit LB1 must also equal one. Omitted LB2 selects Col equal to ValidCol.","Omitted B.IOR selects start zero and ascending direction. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.","Omitted B.DATR selects the operation defaults. A present B.DATR is legal only when every encoded field is zero. Physical padding is always Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TCI, U16; B.DIM LB0=16; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<1>; BSTOP"],"exceptions":["Malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, direction other than zero or one, or a nonzero inapplicable B.DATR field raises Fault_TileLegality before allocation.","An unrepresentable shape, unavailable renamed destination, insufficient TSize, or exhausted Tile capacity raises Fault_TileAllocation before allocation.","PE_MASK zero completes as a strict no-op before every validation or effect."],"field_contracts":{},"field_zero_meanings":{"B.IOR":"Omission selects start zero and ascending; encoded zero selectors explicitly read GPR0 and produce the same operand values.","B.DATR":"All fields zero; every nonzero field is inapplicable.","B.DIM.LB1":"Omission selects one; an explicit value must equal one."},"legality":["TCI is selected by the TEPL encoding carrier Mode 3 Function 6, canonically assembled with BSTART.SFU, and has no standalone opcode.","Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.","The selected DataType is exactly S32, S16, U32, or U16. The destination is row-major, ValidRow is one, ValidCol is nonzero, and Col is at least ValidCol.","A present B.IOR consumes RegSrc0 as the raw start value and RegSrc1 as an exact zero or one direction. Bits above the selected start width are ignored. RegSrc2 and RegDst are zero.","Every explicit nonzero B.DATR field is illegal. PE_MASK zero is a strict no-op before GPR reads, descriptor checks, allocation, faults, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local S32, S16, U32, or U16 destination"},{"field":"scalar0","role":"typed sequence start"},{"field":"flag0","role":"ascending or descending direction"}],"ordering":["Complete schema, type, dimensions, TSize, direction, mask, destination-name, and allocation preflight precedes the private-GPR snapshots.","The sequence payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For logical column k, ascending TCI writes start plus k and descending TCI writes start minus k.","Sequence arithmetic wraps modulo the selected element width. Only ValidRow zero participates.","Every physical destination coordinate outside the one-row valid region is undefined Null padding."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA","PTO-TILE-MODEL-EXECUTION-GENERATION"],"engine":"SFU","id":"PTO-TILE-TCI","mnemonic":"TCI","summary":"Generate one ascending or descending typed integer sequence in a new single-row Local Tile.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCI-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCI MUST select SFU Mode 3 Function 6. It MUST publish one newly allocated
// row-major Local S32, S16, U32, or U16 destination with ValidRow equal to
// one. Logical column k MUST contain start+k for ascending direction or
// start-k for descending direction, modulo the selected element width.
// Omitted B.IOR MUST select start zero and ascending direction.
// NDF-END: PTO-TCI-CONTRACT-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TCI() => TileOperation
begin
    return TileOperation_TCI;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TCI(
    data_type: TileDataType) => boolean
begin
    return TileTCIDataTypeSupported(data_type);
end;

pure func InstructionContractDefaultStart_TCI() => Word
begin
    return Zeros{PTO_XLEN};
end;

pure func InstructionContractDefaultDescending_TCI() => boolean
begin
    return FALSE;
end;

readonly func InstructionContractOperandsLegal_TCI(
    destination: TileIndex,
    start: Word,
    descending: boolean) => boolean
begin
    return TileOperandsLegal_TCI(
        destination,
        start,
        descending);
end;

readonly func InstructionContractHandler_TCI() => TileSemanticHandler
begin
    return TileHandler_TCI;
end;

func InstructionContractExecute_TCI(
    destination: TileIndex,
    start: Word,
    descending: boolean)
begin
    assert InstructionContractOperandsLegal_TCI(
        destination,
        start,
        descending);
    TCI(
        destination,
        start,
        descending);
end;
// DOC-END: operation
