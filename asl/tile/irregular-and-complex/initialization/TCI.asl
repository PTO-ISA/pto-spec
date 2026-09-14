// PTO-INSTRUCTION: {"assembly":["TCI <bundle operands>"],"block":["BSTART.SFU TCI, S32|S16|U32|U16","B.DATR RowMajor all-zero (optional), or explicit CUBE_M32/CUBE_M16 tuple","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (RowMajor optional, default 1; when present must equal 1; CUBE required positive)","B.DIM LB2=Col (RowMajor optional, default ValidCol; CUBE optional; omitted aligns ValidCol to the cell-column quantum)","RowMajor: B.IOR Start, Direction (optional; omission selects 0 and ascending)","CUBE: exactly one B.IOR StartGPR, Step2DGPR, zero, ->zero","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"catalog_indices":[68],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"scalar0"},{"operand":"flag0"}],"command_mnemonic":"BSTART.TEPL","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["DataType","Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TCI","family":"TEPL","fault_contract":"ExecuteTileInstruction","function":6,"legality_handler":"TileOperandsLegal_TCI","mode":3,"name":"TCI","operands":[{"field":"destination0","role":"new Local S32, S16, U32, or U16 destination"},{"field":"scalar0","role":"typed sequence start from RegSrc0"},{"field":"flag0","role":"RowMajor direction from RegSrc1 or CUBE packed Step2D from RegSrc1"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","selector":"0x066","semantic_handler":"TCI","state_effects":["operand:destination0:new-local-integer-destination","operand:scalar0:typed-sequence-start","operand:flag0:RowMajor-direction-or-CUBE-Step2D","runtime:TilePad_Null:physical-padding"]}],"classification":["irregular-and-complex","initialization"],"contract":{"block_composition":["BSTART.SFU TCI, S32|S16|U32|U16","B.DATR RowMajor all-zero (optional), or explicit CUBE_M32/CUBE_M16 tuple","B.DIM LB0=ValidCol","B.DIM LB1=ValidRow (RowMajor optional, default 1; when present must equal 1; CUBE required positive)","B.DIM LB2=Col (RowMajor optional, default ValidCol; CUBE optional; omitted aligns ValidCol to the cell-column quantum)","RowMajor: B.IOR Start, Direction (optional; omission selects 0 and ascending)","CUBE: exactly one B.IOR StartGPR, Step2DGPR, zero, ->zero","B.IOT mask=PE_MASK, <last>, ->DstTile<TSize>","BSTOP"],"canonical_assembly":["TCI <bundle operands>"],"defaults":["RowMajor retains the existing defaults: LB0 is required and supplies nonzero ValidCol. Omitted LB1 selects ValidRow one; an explicit LB1 must also equal one. Omitted LB2 selects Col equal to ValidCol.","Omitted B.IOR selects start zero and ascending direction. An explicitly present all-zero B.IOR is a distinct descriptor with the same operand values.","CUBE is selected only by explicit B.DATR Layout=CUBE_M32 (29) or CUBE_M16 (31); its present B.DATR must use DataType=DTYPE_NONE, Pad=0, CMode=0, RMode=0, Sat=0, and Canonicalize=0.","CUBE omitted LB2 selects Col=align_up(ValidCol, TileCubeCellColumns(Layout, DataType)); explicit Col is never rounded. CUBE requires one canonical B.IOR with StartGPR, packed Step2DGPR, zero, and ->zero. Physical padding is always Null."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.SFU TCI, U16; B.DIM LB0=16; B.IOR a0, a1; B.IOT mask=1111, <last>, ->T0<1>; BSTOP","BSTART.SFU TCI, U16; B.DATR CUBE_M16, DTYPE_NONE, 0, 0, 0, 0, 0; B.DIM LB0=3; B.DIM LB1=2; B.DIM LB2=4; B.IOR StartGPR, Step2DGPR, zero, ->zero; B.IOT mask=1111, <last>, ->T0<1>; BSTOP"],"exceptions":["RowMajor keeps the existing Fault_TileLegality rules for malformed bindings, B.IOS, unsupported DataType, non-row-major layout, missing or invalid dimensions, direction other than zero or one, and nonzero inapplicable B.DATR fields.","CUBE malformed command/B.IOR structure raises Fault_BundleControl; invalid selectors, tuple, dimensions, steps, alignment, or representability raise Fault_TileLegality; a legal CUBE geometry with insufficient explicit TSize or exhausted Tile capacity raises Fault_TileAllocation. All reject before allocation/publication.","PE_MASK zero completes as a strict no-op before every validation, GPR read, descriptor check, allocation, fault, and payload effect."],"field_contracts":{},"field_zero_meanings":{"B.IOR":"RowMajor omission selects start zero and ascending; CUBE requires explicit StartGPR and packed Step2DGPR with source2 and destination zero.","B.DATR":"RowMajor omission or all-zero selects the legacy form; CUBE requires the explicit CUBE_M32/CUBE_M16 plus DTYPE_NONE tuple.","B.DIM.LB0":"LB0 supplies nonzero logical ValidCol.","B.DIM.LB1":"Omission selects ValidRow one; RowMajor explicit value must also equal one; CUBE M16 permits at most one M16 row block and CUBE M32 permits any positive row count.","B.DIM.LB2":"RowMajor omission selects Col=ValidCol; CUBE omission selects the aligned physical Col and explicit Col is exact."},"legality":["TCI is selected by the TEPL encoding carrier Mode 3 Function 6, canonically assembled with BSTART.SFU, and has no standalone opcode.","Exactly one terminating destination-only Local B.IOT supplies one newly allocated destination. Every source binding, a second B.IOT, B.IOS, or an unterminated binding stream is illegal.","The selected DataType is exactly S32, S16, U32, or U16. The existing RowMajor form remains one-row with ValidRow one, ValidCol nonzero, and Col at least ValidCol.","The CUBE form is selected only by explicit Layout CUBE_M32 (29) or CUBE_M16 (31), uses a Matrix-location Local numeric destination, and retains one exact TileInfo.columns physical Col independently of ValidCol.","CUBE M16 requires ValidRow>0 and ValidRow<=16; CUBE M32 accepts every positive ValidRow. Both forms require ValidCol<=Col and a cell-column-aligned explicit Col.","CUBE B.DATR is exactly {Layout=CUBE_M32/CUBE_M16, DataType=DTYPE_NONE, Pad=0, CMode=0, RMode=0, Sat=0, Canonicalize=0}.","CUBE B.IOR is exactly StartGPR, packed Step2DGPR with signed s32 RowStep in bits [63:32] and signed s32 ColStep in bits [31:0], then zero and ->zero. Each step is exactly -1, 0, or +1.","For every logical [0,ValidRow) x [0,ValidCol), CUBE writes trunc_W(Start + r*RowStep + c*ColStep) through the physical CELL mapping. TCI.COL and TCI.ROW spellings are reader-only aliases for the four unit-step tuples and do not add an opcode, selector, or catalog identity.","PE_MASK zero is a strict no-op before GPR reads, validation, allocation, faults, or payload effects."],"memory_effects":["none"],"operands":[{"field":"destination0","role":"new Local S32, S16, U32, or U16 destination"},{"field":"scalar0","role":"typed sequence start from RowMajor/CUBE RegSrc0"},{"field":"flag0","role":"RowMajor direction or CUBE packed Step2D from RegSrc1"}],"ordering":["Complete schema, form/type, dimensions, exact CUBE Col, TSize, step/selector, mask, destination-name, and capacity preflight precedes private-GPR snapshots.","The sequence payload, Null padding definedness, and renamed destination descriptor publish atomically; rejection publishes none."],"standalone_opcode":false,"state_effects":["For RowMajor logical column k, ascending TCI writes start plus k and descending TCI writes start minus k.","RowMajor sequence arithmetic wraps modulo the selected element width; only its ValidRow=1 row participates.","For CUBE, sequence arithmetic wraps modulo the selected element width over the logical rectangle [0,ValidRow) x [0,ValidCol).","For RowMajor, every physical destination coordinate outside the one-row valid region is undefined Null padding.","For CUBE, every physical destination coordinate outside the valid rectangle is undefined Null padding."]},"depends_on":["PTO-BLOCK-MODEL-DISPATCH-GENERATION-SCHEMA","PTO-TILE-MODEL-EXECUTION-GENERATION"],"engine":"SFU","id":"PTO-TILE-TCI","mnemonic":"TCI","summary":"Generate a typed integer sequence in a new Local Tile, retaining RowMajor and adding explicit CUBE_M16/CUBE_M32 forms.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TCI-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TCI MUST select SFU Mode 3 Function 6. It MUST publish one newly allocated
// row-major Local S32, S16, U32, or U16 destination with ValidRow equal to
// one. Logical column k MUST contain start+k for ascending direction or
// start-k for descending direction, modulo the selected element width.
// Omitted B.IOR MUST select start zero and ascending direction.
// The additive CUBE form MUST be selected only by explicit B.DATR Layout
// CUBE_M32 (29) or CUBE_M16 (31), with DataType=DTYPE_NONE, Pad=0, CMode=0,
// RMode=0, Sat=0, and Canonicalize=0. It MUST publish a newly allocated Local
// numeric Matrix-location destination whose DataType remains the BSTART
// carrier type.
// CUBE B.IOR MUST be exactly StartGPR, packed Step2DGPR, zero, ->zero;
// Step2DGPR[63:32] is signed RowStep and [31:0] is signed ColStep, each
// exactly -1, 0, or +1. For every logical [0,ValidRow) x [0,ValidCol), CUBE
// MUST write trunc_W(Start + r*RowStep + c*ColStep) through the physical CELL
// mapping. CUBE M16 requires 0<ValidRow<=16; CUBE M32 accepts any positive
// ValidRow. LB2 is exact physical Col, independently of ValidCol; explicit Col
// is cell-column aligned and omitted Col is align_up(ValidCol, cell quantum).
// CUBE physical tails are Null/undefined, and all schema, tuple, step,
// representability, TSize, and capacity rejection MUST occur before effects.
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
