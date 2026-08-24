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

// A B.SUBVIEW carrier retains the pure descriptor derived from its parent.
// The descriptor is intentionally separate from TileInfo: the parent remains
// the live architectural allocation and the view is a bounded read-only
// interpretation until the selected operation has passed preflight.
type BundleSubviewDescriptor of record {
    valid: boolean,
    parent: TileIndex,
    offset_cells: integer {0..65535},
    origin_row: integer {0..65535},
    origin_column: integer {0..65535},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    cell_count: integer {0..16384},
    capacity_bytes: integer {0..262144}
};

// A portable speculation identity is deliberately opaque.  The instruction
// instance provides replay identity and the execution-domain token separates
// distinct dynamic writers that happen to use the same range.
type PortableSpeculationIdentity of record {
    instruction_instance: Word,
    execution_domain_token: integer
};

type LocalGenerationWriter of record {
    valid: boolean,
    offset_cells: integer {0..2047},
    cell_count: integer {0..2048},
    destination: TileIndex,
    ready: boolean,
    identity: PortableSpeculationIdentity
};

type LocalGenerationWriterSnapshot of array [[16]] of LocalGenerationWriter;

type BundleConsumerDependencyMode of enumeration {
    BundleConsumerDependency_Range,
    BundleConsumerDependency_WholeParent
};

type BundleConsumerDependencyState of enumeration {
    BundleConsumerDependency_Waiting,
    BundleConsumerDependency_Eligible,
    BundleConsumerDependency_Retired,
    BundleConsumerDependency_Cancelled
};

// A consumer dependency is a portable readiness carrier.  It records the
// logical required CELL set and lifecycle without exposing a backend queue or
// physical ready table.
type BundleConsumerDependency of record {
    valid: boolean,
    source: TileIndex,
    generation_instance: Word,
    execution_domain_token: integer,
    mode: BundleConsumerDependencyMode,
    required_cells: bits(2048),
    required_cell_count: integer {0..2048},
    after_last: boolean,
    state: BundleConsumerDependencyState,
    consumer_instruction_instance: Word
};

type BundleConsumerDependencySnapshot of array [[16]] of BundleConsumerDependency;

type BundleProducerEffectClass of enumeration {
    BundleProducerEffect_RollbackSafe,
    BundleProducerEffect_AtomicAuxiliary,
    BundleProducerEffect_NonRollbackAuxiliary
};

// The descriptor captured by INIT is the normalized architectural object
// identity.  It is compared on every later writer before the operation body;
// a matching range alone is not sufficient to rebind an open generation.
type LocalGenerationParentDescriptor of record {
    valid: boolean,
    object_name: TileIndex,
    object_kind: TileStorageKind,
    participant_mask: bits(4),
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    location: TileLocation,
    cube_k_repeat: integer {0..65535},
    cube_n_repeat: integer {0..8192},
    cube_cell_count: integer {0..16384},
    cube_storage_bytes: integer {0..262144}
};

type LocalGenerationState of record {
    open: boolean,
    closed: boolean,
    published: boolean,
    destination_hand: integer {0..3},
    participant_mask: bits(4),
    generation_instance: Word,
    init_tpc: Word,
    init_tpc_valid: boolean,
    parent_size_code: integer {0..12},
    parent_cell_count: integer {0..2048},
    parent_descriptor: LocalGenerationParentDescriptor,
    covered_cells: bits(2048),
    ready_cells: bits(2048),
    writer_count: integer {0..16},
    writers: LocalGenerationWriterSnapshot,
    last_seen: boolean,
    consumers: BundleConsumerDependencySnapshot,
    consumer_count: integer {0..16},
    working_destination: TileIndex,
    published_destination: TileIndex,
    committed_destination: TileIndex,
    committed_valid: boolean
};

// One aggregate state is retained for each architectural hand and each
// decoded four-PE participation mask.  This preserves independent open
// generation domains instead of collapsing distinct selected-PE identities.
type LocalGenerationSnapshot of array [[64]] of LocalGenerationState;

type SharedGenerationState of record {
    open: boolean,
    closed: boolean,
    published: boolean,
    shared_tile_id: SharedTileID,
    participant_mask: bits(4),
    parent_size_code: integer {0..12},
    parent_cell_count: integer {0..2048},
    covered_cells: bits(2048),
    ready_cells: bits(2048),
    last_seen: boolean,
    working_valid: boolean,
    working_tile: TileInfo,
    working_initialized_mask: bits(4)
};

type SharedGenerationSnapshot of array [[PTO_SHARED_TILE_COUNT]]
    of SharedGenerationState;

// Range modifiers are retained as decoded carriers until the enclosing
// B.IOT/B.IOS syntax group is closed.  `offset` is the XLEN-wrapped result of
// GPR[reg_src] + zero-extended uimm11; the carrier is deliberately inert until
// the later bundle schema consumes it.
type BundleRangeModifier of record {
    valid: boolean,
    reg_src: Reg5Selector,
    uimm11: bits(11),
    size_code: integer {0..12},
    offset: Word,
    init: boolean,
    last: boolean,
    derived: BundleSubviewDescriptor,
    materialized: boolean,
    materialized_index: TileIndex
};

type BundleRangeGroupKind of enumeration {
    BundleRangeGroup_None,
    BundleRangeGroup_Local,
    BundleRangeGroup_Shared
};

// This is syntactic header state only.  It records the immediately preceding
// binder and modifier roles; destination allocation and operation binding stay
// deferred to bundle closure.
type BundleRangeGroupState of record {
    open: boolean,
    zero_mode: boolean,
    kind: BundleRangeGroupKind,
    tile_binding: integer {0..15},
    shared_binding: integer {0..3},
    source0_allowed: boolean,
    source1_allowed: boolean,
    destination_allowed: boolean,
    source0_seen: boolean,
    source1_seen: boolean,
    destination_seen: boolean
};

type BundleTileBinding of record {
    valid: boolean,
    destination_valid: boolean,
    destination: TileIndex,
    destination_hand: bits(2),
    destination_allocated_by_bundle: boolean,
    destination_reused_by_generation: boolean,
    destination_size: integer {0..15},
    pe_mask: bits(4),
    source0_valid: boolean,
    source1_valid: boolean,
    source0: TileIndex,
    source1: TileIndex,
    last: boolean,
    source0_subview: BundleRangeModifier,
    source1_subview: BundleRangeModifier,
    destination_assemble: BundleRangeModifier
};

type BundleSharedBinding of record {
    valid: boolean,
    shared_tile_id: SharedTileID,
    size_code: integer {0..12},
    pe_mask: bits(4),
    consumed: boolean,
    source0_subview: BundleRangeModifier,
    destination_assemble: BundleRangeModifier
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
    max_abs_en: boolean,
    trans_a: boolean,
    trans_b: boolean
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
