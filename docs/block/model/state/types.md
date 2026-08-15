<!-- GENERATED FROM: asl/block/model/state/types.asl -->
# Types

**Normative ASL source:** `asl/block/model/state/types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-TYPES}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/state/types.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-STATE-TYPES","surface":"block","classification":["model","state","types"],"depends_on":["PTO-ARCH-DATA-TYPES-FAULT"]}
type BundleKind of enumeration {
    BundleKind_Standard,
    BundleKind_Floating,
    BundleKind_System,
    BundleKind_TileElement,
    BundleKind_TileMemory,
    BundleKind_TileMatrix,
    BundleKind_FrameTemplate
};

type BundleTransfer of enumeration {
    BundleTransfer_Fallthrough,
    BundleTransfer_Direct,
    BundleTransfer_Conditional,
    BundleTransfer_Call,
    BundleTransfer_Return,
    BundleTransfer_Indirect,
    BundleTransfer_IndirectCall
};

// BARG is the single architectural continuation record installed by BSTART.
// BPC is stored by the architectural program-control state; the remaining
// fields are stored here and are consumed only at the block commit boundary.
type BundleArgumentRegister of record {
    block_type: BundleKind,
    transfer_type: BundleTransfer,
    taken: boolean,
    bpcn: Word
};

// A bundle start always installs one descriptor. Control-only starts retain
// their exact form and modifiers, while operation-bearing starts additionally
// carry the selector consumed when the bundle is committed.
// PTO-REQ-BUNDLE-OPERATION-001: exact start fields survive decode and commit.
type BundleOperationClass of enumeration {
    BundleOperation_Control,
    BundleOperation_TileElement,
    BundleOperation_TileMemory,
    BundleOperation_TileMatrix,
    BundleOperation_FixedPoint
};

type BundleOperationDescriptor of record {
    valid: boolean,
    form_identity: bits(7),
    operation_class: BundleOperationClass,
    selector_valid: boolean,
    selector: bits(10),
    data_type_valid: boolean,
    data_type: bits(5),
    mode_valid: boolean,
    mode: bits(2),
    branch_type_valid: boolean,
    branch_type: bits(3)
};

type BundleScalarBinding of record {
    valid: boolean,
    destination: Reg5Selector,
    source0: Reg5Selector,
    source1: Reg5Selector,
    source2: Reg5Selector,
    source_count: integer {0..3}
};

type BundleTileBinding of record {
    valid: boolean,
    destination_valid: boolean,
    destination: TileIndex,
    destination_hand: bits(2),
    destination_allocated_by_bundle: boolean,
    destination_size: integer {0..15},
    pe_mask: bits(4),
    source0_valid: boolean,
    source1_valid: boolean,
    source0: TileIndex,
    source1: TileIndex,
    last: boolean
};

type BundleSharedBinding of record {
    valid: boolean,
    shared_id: bits(8),
    size_code: integer {0..7},
    pe_mask: bits(4),
    consumed: boolean
};

type BundleControlAttributes of record {
    present: boolean,
    trap_enabled: boolean,
    atomic: boolean,
    acquire: boolean,
    release: boolean,
    far: boolean,
    dimension_reduction: boolean
};

type BundleDataAttributes of record {
    data_type_present: boolean,
    data_type: bits(5),
    data_layout: bits(5),
    pad_value: bits(2),
    comparison_mode: bits(3),
    rounding_mode: bits(3),
    saturating: boolean,
    canonicalize: boolean
};

type BundleHintAttributes of record {
    present: boolean,
    trace: boolean,
    trace_end: boolean,
    branch_valid: boolean,
    branch_likely: boolean,
    temperature: bits(2),
    prefetch_size: bits(12)
};

// B.FPATR is a complete-bundle post-processing descriptor.  `valid` tracks
// encoded presence separately from the field values so omission, duplicate
// headers, and encoded zero remain distinct at bundle commit.
type BundleFixedPointAttributes of record {
    valid: boolean,
    pre_quant_mode: bits(6),
    relu_mode: bits(3),
    group_n_code: bits(4),
    row_max_en: boolean,
    group_max_en: boolean,
    row_max_init: boolean,
    max_abs_en: boolean
};

// MCOPY retains the complete operand snapshot and the next byte offset across
// a recoverable memory fault.  Progress names the first byte not yet committed.
type MemoryCopyTemplateState of record {
    active: boolean,
    instruction_pc: Word,
    destination: Word,
    source: Word,
    length: Word,
    progress: Word
};

type FrameTemplateKind of enumeration {
    FrameTemplate_Entry,
    FrameTemplate_Exit,
    FrameTemplate_ReturnAddress,
    FrameTemplate_ReturnStack
};

type FrameRegisterCount of integer {0..22};
type FrameRegisterOrdinal of integer {0..21};
type FrameRegisterSnapshot of array [[22]] of Word;

// Frame-template progress names the next register memory event that has not
// committed.  Source values are retained before FENTRY changes sp, and the
// whole record survives a recoverable memory fault.
type FrameTemplateState of record {
    active: boolean,
    kind: FrameTemplateKind,
    instruction_pc: Word,
    begin_reg: Reg5Selector,
    end_reg: Reg5Selector,
    register_count: FrameRegisterCount,
    frame_size: Word,
    caller_sp: Word,
    stack_adjusted: boolean,
    progress: FrameRegisterCount,
    return_target: Word,
    return_target_valid: boolean,
    source_values: FrameRegisterSnapshot
};

// ACR0 is the root ring. The active profile defines permissions and the
// implemented Access Control Ring subtree.
type AccessControlRing of integer {0..15};
type TemporaryQueueSnapshot of array [[PTO_TEMPORARY_QUEUE_DEPTH]] of Word;
type TemporaryQueueValiditySnapshot of array
    [[PTO_TEMPORARY_QUEUE_DEPTH]] of boolean;
type PredicateSnapshot of array [[PTO_PREDICATE_REGISTER_COUNT]]
    of PredicateWord;
type BundleDimensionSnapshot of array [[PTO_BUNDLE_DIMENSION_COUNT]] of Word;
type BundleDimensionPresenceSnapshot of array [[PTO_BUNDLE_DIMENSION_COUNT]]
    of boolean;
type BundleScalarBindingSnapshot of array [[PTO_BUNDLE_SCALAR_BINDING_COUNT]]
    of BundleScalarBinding;
type BundleTileBindingSnapshot of array [[PTO_BUNDLE_TILE_BINDING_COUNT]]
    of BundleTileBinding;
type BundleSharedBindingSnapshot of array [[4]] of BundleSharedBinding;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
