// PTO-INSTRUCTION: {"assembly":["TMOV <bundle operands>"],"block":["BSTART.TLSU TMOV, DataType","B.DIM LB0","B.DIM LB1 (optional)","B.DIM LB2 (optional)","B.IOT","BSTOP"],"catalog_indices":[74],"catalog_records":[{"arguments":[{"operand":"destination0"},{"operand":"source0"}],"command_mnemonic":"BSTART.TMOV","contract_status":"reviewed-complete","datr_contract":{"allowed_nonzero_fields":["Layout"],"pad_union":"must-zero"},"disposition":"accepted-direct-operation","effect_contract":"TMOV","family":"TLSU","fault_contract":"ExecuteTileInstruction","function":2,"legality_handler":"TileOperandsLegal_TMOV","name":"TMOV","operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"restart_contract":"CompleteBundleAtWithAcceptedApplicabilityRules","semantic_handler":"TMOV","state_effects":["operand:destination0:destination","operand:source0:source"]}],"classification":["layout-and-rearrangement","layout"],"contract":{"block_composition":["BSTART.TLSU TMOV, DataType","B.DIM LB0","B.DIM LB1 (optional)","B.DIM LB2 (optional)","B.IOT","BSTOP"],"canonical_assembly":["TMOV <bundle operands>"],"defaults":["At BSTART the bundle descriptor begins with zero-valued B.DATR and B.DIM state; omitted optional commands retain those reset values, and an encoded zero is a value rather than absence.","The TileOperandsLegal_TMOV schema determines which B.IOR, B.IOT, B.IOS, B.DATR, and B.DIM bindings are required or optional for TMOV."],"encoding_class":"selector-encoded-block-operation","examples":["BSTART.TLSU TMOV, DataType; B.DIM LB0; B.DIM LB1 (optional); B.DIM LB2 (optional); B.IOT; BSTOP"],"exceptions":["ExecuteTileInstruction supplies the operation fault contract; illegal bundles and reserved selector combinations reject before architectural effects.","CompleteBundleAtWithAcceptedApplicabilityRules supplies restart and completion behavior after an accepted operation."],"field_contracts":{},"field_zero_meanings":{},"legality":["TMOV is selected only by its BSTART carrier and selector/function assignment; it has no standalone opcode.","Before effects, TileOperandsLegal_TMOV validates the complete assembled bundle, operand roles, dimensions, data attributes, and applicability.","B.DATR applicability is exactly [{\"allowed_nonzero_fields\":[\"Layout\"],\"pad_union\":\"must-zero\"}].","The selected DataType is a carrier interpretation. Each non-packed source backing DataType may differ only at the same element width, and the newly allocated destination preserves the source backing DataType; multi-source operations require one common backing DataType.","A Local CUBE_M32 operand backed by FP64, S64 or U64 uses the issue #371 two-CELL-per-column mapping and logical effect coordinates when its operation type is otherwise legal; CUBE_M16 does not admit b64 backing storage.","Function-2 Local CUBE_M32/M16 to Shared ND uses B.DATR Layout M322ND/M162ND with DTYPE_NONE; it copies raw valid coordinates into normalized ND fragments and retains source backing type under carrier-compatible preflight. Function-2 Shared RowMajor ND to Local CUBE_M32/M16 uses ND2M32/ND2M16 under PTO-TMOV-SHARED-ND-TO-CUBE-001."],"memory_effects":["Perform only the global, Local, or Shared data movement named by the mnemonic after complete access, shape, stride, and descriptor validation; a fault produces no partial destination or memory effect."],"operands":[{"field":"destination0","role":"destination"},{"field":"source0","role":"source"}],"ordering":["none"],"standalone_opcode":false,"state_effects":["Copy the source Tile payload and definedness into the destination.","After complete preflight, execute TMOV with the operand bindings listed above; destination definedness changes only as specified by that handler. A reverse ND2M32/ND2M16 form reads valid Shared logical coordinates only, preserves raw bits and backing type, zero-initializes output padding, and commits one Local CUBE destination per participating PE without modifying Shared state.","A Local CUBE-to-Shared ND form normalizes each valid raw source coordinate, then publishes a complete singleton parent or commits an explicit B.ASSEMBLE range through the existing atomic Shared generation."]},"depends_on":["PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA"],"engine":"TLSU","id":"PTO-TILE-TMOV","mnemonic":"TMOV","summary":"Copy the source Tile payload and definedness into the destination.","surface":"tile"}
// PTO-REVIEW: {"review_method":"formal-definition-read","outcome":"FORMAL-COMPLETE","reviewed_fields":["assembly","encoding","defaults","operation","state","memory","ordering","faults","reserved"]}
// NDF-BEGIN: PTO-TMOV-CONTRACT-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local TMOV MUST copy payload and per-element definedness from one persistent
// Local source to one renamed Local destination after exact shape and carrier-width preflight.
// Shared INSERT, PUBLISH, BROADCAST, and EXTRACT modes MUST use the distinct
// BSTART.TMOV schemas and MUST preserve the accepted publication rules.
// Function-2 Local CUBE_M32/M16 to Shared ND MUST use B.DATR Layout M322ND or
// M162ND with DataType=DTYPE_NONE, preserve raw bits/backing type, normalize
// only valid logical coordinates, and use the existing explicit B.ASSEMBLE
// range and atomic generation publication. NORM, M322ND, and M162ND MUST NOT
// mix within one Shared generation.
// The selected DataType MUST be a carrier interpretation. A non-packed source
// backing type MAY differ only at the same element width, and the renamed
// destination MUST preserve the source backing type.
// Function-2 Shared-to-Local CUBE forms are limited to Layout ND2M32/ND2M16
// and are governed by PTO-TMOV-SHARED-ND-TO-CUBE-001. They preserve the
// existing NORM and Local-CUBE-to-Shared forms without changing their schema.
// NDF-END: PTO-TMOV-CONTRACT-001
// NDF-BEGIN: PTO-TMOV-CUBE-TO-SHARED-ND-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Function-2 TMOV with DTYPE_NONE and B.DATR Layout M322ND/M162ND MUST read a
// completed Local CUBE_M32/M16 source and copy each valid raw logical (row,col)
// into the same coordinate of a RowMajor ND Shared fragment. BSTART.DataType
// MUST be carrier-compatible with the source backing type; Shared MUST retain
// that backing type and no numerical conversion or CUBE padding copy occurs.
// A fragment's capacity MUST equal B.ASSEMBLE.WriterSizeCode and its physical
// columns MUST match the ND parent. B.ASSEMBLE's explicit linear range places
// that fragment within the parent; a singleton without B.ASSEMBLE transfers a
// complete parent. One Shared generation MUST NOT mix NORM, M322ND, and M162ND.
// Publication MUST use the existing atomic Shared generation protocol.
// NDF-END: PTO-TMOV-CUBE-TO-SHARED-ND-001
// NDF-BEGIN: PTO-TMOV-SHARED-ND-TO-CUBE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Function-2 TMOV with B.DATR.DataType=DTYPE_NONE and Layout ND2M32 or
// ND2M16 MUST read exactly one whole-ready, published RowMajor ND Shared
// source and create one newly allocated Local CUBE_M32 or CUBE_M16 destination
// per participating PE. The selected Layout determines the destination layout
// and physical row count M (32 or 16); the source backing type determines the
// persistent destination type. BSTART.TMOV's concrete carrier type MUST satisfy
// the existing TileCarrierWidthCompatible relation for that backing type.
// The only other accepted Shared-to-Local schema is the unchanged NORM form.
//
// The source is either the complete Shared parent, whose physical row count is
// exactly M, or one explicit source0 B.SUBVIEW selecting exactly M contiguous
// complete physical ND rows. A subview MUST start at a physical row boundary,
// retain the parent's physical column count and row stride, fit within the
// parent's physical rows, and have the exact byte capacity used by the Local
// destination. The starting row need not be a multiple of M. No arbitrary
// strided two-dimensional selection or implicit PE-index partition is legal.
// Each participating PE reads only its own encoded B.SUBVIEW offset. Both
// bindings MUST use the same nonzero PE mask; no Local mathematical source,
// additional Shared binding, B.ASSEMBLE, scalar/execution-mask binding, or
// unsupported DATR control is permitted. PE_MASK zero retains the strict
// existing no-effect behavior before source inspection.
//
// For the selected fragment, ValidRow is min(M, max(0, parent.ValidRow minus
// origin_row)) and ValidCol is parent.ValidCol. Both MUST be nonzero. LB0 MUST
// equal ValidCol and LB1 MUST equal ValidRow. Physical columns MUST be derived
// from the exact destination capacity, selected CUBE layout, and source backing
// type, and MUST equal the Shared parent's physical column count. For this
// conversion only, the effective LB2 value 1 requests that derived physical
// column count; omission and explicit one are equivalent. Any other LB2 value
// MUST equal the derived count, and zero or any mismatch is illegal. Legality
// MUST consume the effective value and MUST NOT inspect the LB2 presence bit.
//
// After complete per-PE preflight, every valid destination coordinate (r,c)
// MUST receive the raw bits of SharedND(origin_row+r,c) without arithmetic,
// transpose, reinterpretation, or numeric conversion. Only valid source
// coordinates may be read; undefined valid source data rejects. Destination
// positions outside the valid region MUST be initialized to raw zero and MUST
// remain outside the semantic valid region. Mark valid output elements defined
// and publish the complete Local descriptor and payload through the existing
// Local destination commit path. A successful conversion MUST NOT modify the
// Shared payload or create a Shared generation.
//
// An unready or unpublished source waits without consuming the binding or
// creating a Local effect. Descriptor, role, mask, DATR, dimension, subview,
// carrier, definedness, capacity, and destination checks MUST complete before
// Local payload/publication effects. A fault rolls back only the current PE's
// attempt; it MUST NOT undo an earlier successful PE or mutate/retire the
// Shared source. No GM access, implicit barrier, latency, or throughput
// guarantee is introduced.
// NDF-END: PTO-TMOV-SHARED-ND-TO-CUBE-001
// DOC-BEGIN: decode
readonly func InstructionContractOperation_TMOV() => TileOperation
begin
    return TileOperation_TMOV;
end;
// DOC-END: decode
// DOC-BEGIN: operation
readonly func InstructionContractHandler_TMOV() => TileSemanticHandler
begin
    return TileHandler_TMOV;
end;

readonly func InstructionContractOperandsLegal_TMOV(
    destination: TileIndex,
    source: TileIndex) => boolean
begin
    return TileOperandsLegal_TMOV(destination, source);
end;

func InstructionContractExecute_TMOV(
    destination: TileIndex,
    source: TileIndex)
begin
    assert InstructionContractOperandsLegal_TMOV(destination, source);
    TMOV(destination, source);
end;
// DOC-END: operation
