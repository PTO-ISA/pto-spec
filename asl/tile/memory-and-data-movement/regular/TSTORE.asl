// PTO-INSTRUCTION: {"assembly":["TSTORE <bundle operands>"],"block":["Local: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM; optional B.IOR; one source B.IOT; BSTOP","Shared: BSTART.TSTORE DataType; optional B.DATR/B.DIM/B.IOR; one source B.IOS with any nonzero consumer PE_MASK; optional B.SUBVIEW; BSTOP"],"catalog_indices":[73],"catalog_records":[{"arguments":[{"operand":"address"},{"operand":"scalar0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TSTORE","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["PadValueOrByteId","Layout","DataType","Canonicalize","CMode"],"pad_union":"pad-value"},"disposition":"accepted-direct-operation","effect_contract":"TSTORE","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":1,"legality_handler":"TileOperandsLegal_TSTORE","name":"TSTORE","operands":[{"field":"address","role":"base-address"},{"field":"scalar0","role":"row-stride-bytes"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TSTORE","state_effects":["operand:address:base-address","operand:scalar0:row-stride-bytes","operand:source0:source"]}],"classification":["memory-and-data-movement","regular"],"contract":{"block":["Local: BSTART.TSTORE DataType; optional B.DATR Layout; optional B.DIM; optional B.IOR; one source B.IOT; BSTOP","Shared: BSTART.TSTORE DataType; optional B.DATR/B.DIM/B.IOR; one source B.IOS with a nonzero consumer PE_MASK; optional B.SUBVIEW; BSTOP"],"block_composition":["The Local form uses TLSU Function 1, exactly one terminating source B.IOT, at most one B.IOR, and no B.IOS.","The Shared form uses canonical TLSU Function 1, exactly one source B.IOS, at most one B.IOR, no B.IOT, and any nonzero consumer PE_MASK; optional B.SUBVIEW supplies the only partial-source range.","The Local CUBE form uses Function 1, explicit B.DATR M322ND, M162ND, or N82ND with DTYPE_NONE, explicit LB0/LB1, absent LB2, and one persistent source B.IOT."],"canonical_assembly":["TSTORE <bundle operands>"],"defaults":["DataType is explicit in BSTART.TSTORE. Omitted B.DATR selects ordinary NORM layout. Ordinary and Shared forms require PadValue zero; Local CUBE codes 24 through 26 require DTYPE_NONE, accept all four PadValue encodings, and ignore physical padding while storing only valid elements.","Omitted LB0, LB1, and LB2 each have effective value one. The resolved dimensions are checked against the source descriptor; omission does not inherit its shape.","An unallocated, pending, or incomplete Shared source remains waiting and produces no GM, binding-consumption, or descriptor effect.","Omitted B.IOR supplies base zero. Ordinary forms use resolved Col and CUBE forms use LB0 valid columns to derive dense byte row stride as ceil(columns * element_bits / 8). An encoded zero selector is present and supplies the real zero GPR value, so an explicitly encoded zero stride aliases rows."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TSTORE U8; B.DIM LB0, 64; B.DIM LB1, 8; B.DIM LB2, 64; B.IOR a0, a1; B.IOT T1, mask=1111, last; BSTOP","BSTART.TSTORE FP16; B.IOS S7, mask=0011; B.SUBVIEW 0, a0, 0, 7; BSTOP"],"exceptions":["A malformed binding stream, missing dimensions, unsupported DataType, non-row-major source, undefined Local source element, invalid source encoding, or mismatched source geometry raises Fault_TileLegality before effects. An unpublished or not-whole-ready Shared source waits without fault or effect.","For Normal TSTORE, a memory translation, permission, or alignment fault stops the request at the first fault; prior GM writes and memory events may remain visible. Atomic Function 1 TSTORE preflights the complete selected-PE footprint and produces no Atomic effects on a failed preflight."],"field_contracts":{"DataType":{"ref":"PTO-FIELD-BLOCK-DATATYPE"}},"field_zero_meanings":{"B.IOR.RegSrc0":"An encoded zero GPR supplies base address zero; omission also defaults the base to zero but remains a distinct schema state.","B.IOR.RegSrc1":"An encoded zero GPR supplies row stride zero; omission defaults the stride to the dense byte row width derived from resolved Col and DataType.","B.IOS.PE_MASK":"0000 is a strict no-op before schema, descriptor, GPR, memory, fault, or source-consumption effects."},"legality":["TSTORE is selected by TLSU Function 1 and has no standalone opcode.","DataType accepts 0..14, 16..20, and 24..28; all other codes are reserved before effects.","The completed block has exactly one source domain. Function 1 accepts one Local B.IOT or one Shared B.IOS; Shared source access requires whole-parent readiness and publication.","Shared PE_MASK selects participating consumer PEs and never infers quarter selection. B.SUBVIEW is the explicit source range mechanism.","ValidCol and ValidRow are nonzero, ValidCol does not exceed physical Col, and the resolved valid rectangle fits the persistent source descriptor.","The existing explicit ND2M32/M322ND Local conversion forms admit FP64, S64 and U64 with 256 physical bytes per column under issue #371; ordinary and Shared form layout rules remain owned separately."],"memory_effects":["Normal TSTORE writes every selected element in ValidRow x ValidCol at base + row * row_stride_bytes + column * element_size. Packed four-bit columns add floor(column / 2) to each byte-strided row base and select low/high by column parity.","Normal TSTORE accesses the selected-PE footprint element by element until the first fault; stores and memory events completed before that fault may remain visible. Atomic Function 1 TSTORE performs one intrinsic Atomic read-modify-write per active occurrence after complete per-PE preflight; occurrences after the first effect drain exactly once despite squash or abort."],"operands":[{"field":"source0","role":"Local Tile or absolute Shared S0..S63 source"},{"field":"address","role":"per-PE private-GPR GM base address"},{"field":"scalar0","role":"per-PE private-GPR byte row stride"}],"ordering":["Normal TSTORE snapshots the source payload, resolves the complete schema and dimensions, validates the source descriptor or temporary descriptor, then accesses each selected GM element until the first fault.","After successful Normal TSTORE completion, store beats have no architecture-defined relative order. Atomic Function 1 TSTORE uses GM atomic serialization for each exact target; no fixed order is imposed across distinct targets or PEs."],"standalone_opcode":false,"state_effects":["Reads one Local or published, whole-parent-ready Shared source without modifying its payload, descriptor, producer mask, readiness, or lifetime.","Normal TSTORE consumes the source binding through ordinary successful block completion. Atomic TSTORE delays captured source last-use until its active occurrences and the existing required-participant generation are complete.","A Shared source that is pending or incomplete causes no payload read and no GM effect."]},"depends_on":["PTO-BLOCK-BSTART-TSTORE","PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING"],"engine":"TLSU","id":"PTO-TILE-TSTORE","mnemonic":"TSTORE","summary":"Store one ordinary Local or Shared rectangle, or explicitly convert persistent Local CUBE storage into one GM rectangle.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TSTORE-MEMORY-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Normal TSTORE MUST use B.IOR RegSrc1 as a byte row stride, MUST snapshot and
// preserve its Local or Shared source, MUST stop at the first memory fault,
// and MUST distinguish an omitted dense byte stride from an explicitly encoded
// zero stride. Stores completed before that fault MAY remain visible in GM and
// in the memory-event stream. Function 1 Shared access accepts any nonzero
// participating PE mask, and mask zero MUST have no architectural effect.
// Atomic Function 1 TSTORE uses the separate per-PE admission, preflight and
// irrevocable-drain contract in PTO-TSTORE-STRIDED-ATOMIC-RED-001.
// NDF-END: PTO-TSTORE-MEMORY-001
// NDF-BEGIN: PTO-TSTORE-CUBE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Normal CUBE TSTORE MUST require an exact persistent Matrix descriptor
// selected by M322ND, M162ND, or N82ND, MUST stop at the first fault while
// storing its valid LB1 by LB0 GM elements, and MUST not modify source or
// padding. Atomic CUBE TSTORE uses PTO-TSTORE-STRIDED-ATOMIC-RED-001.
// NDF-END: PTO-TSTORE-CUBE-001
// NDF-BEGIN: PTO-TSTORE-STRIDED-ATOMIC-RED-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// TLSU Function 1 TSTORE with B.DATR Canonicalize=1 MUST perform no-return,
// no-index per-element GM reductions: CMode 0..7 selects ADD, MIN, MAX, AND,
// OR, XOR, INC, DEC. Virtual aliases TSTORE.ATOMIC_ADD/MIN/MAX/AND/OR/XOR/INC/DEC
// MUST lower to this same BSTART.TSTORE plus B.DATR Canonicalize=1 and the
// corresponding CMode; they MUST NOT add a TileOp or TLSU Function.
// Canonicalize=0,CMode=0 remains Normal TSTORE. Codes
// 6/7 MUST reject at B.DATR except in the active atomic TSTORE context.
// Local B.IOT and whole-parent-published Shared B.IOS sources MUST use the
// existing source schema, PE-private base/byte stride, valid rectangle and
// Word-width AGU, including explicit zero and overlapping strides. Local
// CUBE MUST use M322ND or M162ND, DTYPE_NONE, explicit LB0/LB1, absent LB2;
// CUBE_N8 MUST NOT be admitted. No IndexTile, return, new Function, implicit
// PE partition, fence, publication or source write is introduced.
// Dtype legality and numeric updates MUST use GMReductionOperationDataTypeLegal
// and GMReductionResult. Every active occurrence, including translated exact
// aliases, MUST contribute once in implementation-defined serialization order;
// mixed-size partial overlap remains fail-closed. Inactive/padded coordinates
// MUST NOT probe or update. PE_MASK=0 MUST retain strict no-effect precedence.
// Participating atomic TSTORE with B.CATR.atom=1 MUST fault TileLegality before
// effects; omitted B.CATR or atom=0 MUST retain intrinsic atomicity (A1).
// Before the first effect, a PE MUST snapshot its source and active set and
// preflight every read/write target, translation, permission and alignment.
// Admission MUST freeze operator, dtype, geometry, generation, source values,
// active coordinates, AGU results, validated targets and access context (B1).
// Old GM values MUST be sampled at each RMW, not at admission. Failed preflight
// MUST have zero atomic effects for that PE and MAY revalidate after recovery.
// An admitted request MAY cancel before its first effect; after any effect it
// MUST drain remaining occurrences exactly once despite squash/abort (B2).
// Repeated service MUST NOT repeat committed occurrences; new dynamic requests
// at the same PC MUST remain distinct. No Core4 rollback is introduced.
// If any Atomic TSTORE occurrence remains undrained, its real block-completion
// attempt MUST remain pending without a fault, header clear, or continuation
// advance. A later completion attempt MUST resume that same captured request
// occurrence and MUST NOT reissue committed effects. After the last occurrence
// drains, the existing block commit and post-commit trap path MUST run once.
// Normal TSTORE keeps its existing posted-completion behavior.
// Source capture/admission MUST NOT complete last-use. Existing .reuse and
// required-participant/generation completion MUST govern consumption (C1).
// Existing aq/rl/aqrl/far/trap completion paths remain applicable. Numeric ADD
// MUST follow PTO-GM-FLOATING-ADD-NUMERIC-001 for indexed and strided forms.
// NDF-END: PTO-TSTORE-STRIDED-ATOMIC-RED-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TSTORE() => TileOperation
begin
    return TileOperation_TSTORE;
end;
// DOC-END: decode
// DOC-BEGIN: operation
pure func InstructionContractDataTypeLegal_TSTORE(code: bits(5)) => boolean
begin
    if !TileDataTypeEncodingValid(code as TileDataTypeEncoding) then
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(code as TileDataTypeEncoding);
    return TileRegularTLSUDataTypeSupported(data_type);
end;

readonly func InstructionContractHandler_TSTORE() => TileSemanticHandler
begin
    return TileHandler_TSTORE;
end;

readonly func InstructionContractGMAddress_TSTORE(
    base_address: Word,
    row: integer {0..65535},
    column: integer {0..65535},
    row_stride_bytes: Word,
    data_type: TileDataType) => Word
begin
    return TileMemoryStridedByteAddress(
        base_address, row, column, row_stride_bytes, data_type);
end;

readonly func InstructionContractDenseStride_TSTORE(
    columns: integer {0..65535}, data_type: TileDataType) => Word
begin
    return TileDenseRowStrideBytes(columns, data_type);
end;

pure func InstructionContractSharedMaskLegal_TSTORE(
    function: integer {0..31}, pe_mask: bits(4)) => boolean
begin
    return SharedStorePEMaskLegal(function, pe_mask);
end;

pure func InstructionContractZeroMaskNoEffect_TSTORE(
    pe_mask: bits(4)) => boolean
begin
    return pe_mask == Zeros{4};
end;

pure func InstructionContractCubeDimensionsLegal_TSTORE(
    lb0_present: boolean, lb0: integer {0..65535},
    lb1_present: boolean, lb1: integer {0..65535},
    lb2_present: boolean) => boolean
begin
    return lb0_present && lb0 != 0 &&
           lb1_present && lb1 != 0 && !lb2_present;
end;
// DOC-END: operation
