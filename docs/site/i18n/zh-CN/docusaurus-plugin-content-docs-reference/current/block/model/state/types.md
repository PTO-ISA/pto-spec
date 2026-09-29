<!-- GENERATED FROM: asl/block/model/state/types.asl -->
# Types

**Normative ASL source:** `asl/block/model/state/types.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-STATE-TYPES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-state-types-purpose role=purpose-scope -->
## 用途与范围

本单元声明所有指令束状态使用的枚举和记录类型。它不定义任何转换。阅读它可以了解每个指令束状态变量能保存什么。

<!-- PTO-READER-BLOCK: block-model-state-types-concepts role=concepts-state -->
## 概念与可见状态

主要类型分组如下。

- 指令束标识：`BundleKind`（Standard、Floating、System、TileElement、TileMemory、TileMatrix、FrameTemplate）、`BundleTransfer`（七种转移规则），以及 `BundleArgumentRegister`，即 `BARG` 记录。
- 操作：`BundleOperationClass`（Control、TileElement、TileMemory、TileMatrix、FixedPoint）和 `BundleOperationDescriptor`。
- 绑定：`BundleScalarBinding`、`BundleTileBinding`、`BundleSharedBinding`、`BundleRangeModifier`、`BundleRangeGroupState`、`BundleSubviewDescriptor` 和 `BundleExecutionMaskBinding`。
- 属性：`BundleControlAttributes`、`BundleDataAttributes`、`BundleHintAttributes` 和 `BundleFixedPointAttributes`。
- 代次：`LocalGenerationState`、其写入者记录、父级描述符记录和消费者依赖记录，以及 `SharedGenerationState`。
- 模板：`MemoryCopyTemplateState` 和 `FrameTemplateState`。

快照数组类型固定了各项大小：3 个维度、32 个标量绑定、16 个 Tile 绑定、4 个 Shared 绑定，以及 64 条 Local 代次记录（每个 hand `T`、`U`、`M`、`N` 各 16 条）。

<!-- PTO-READER-BLOCK: block-model-state-types-rules role=rules-interactions -->
## 规则与交互

许多记录在其字段旁边带有一个单独的 `valid` 或 `present` 标志。

设计要点：存在性与取值分开跟踪。`BundleFixedPointAttributes` 上的注释说明，`valid` 使省略、重复头部和编码为零在提交时保持可区分。因此一个全为零的字段仍然可能表示“显式写为零”。

设计要点：`BundleSubviewDescriptor` 与父 Tile 的描述符分开保存。注释说明，父级保持为活动分配，而视图在所选操作通过预检之前是一个有界的只读解释。因此在确知操作合法之前，子视图永远不会自行成为一个 Tile。

设计要点：`BundleExecutionMaskBinding` 是挂起的指令束操作数状态。注释说明它从不会在提交后作为隐式的当前掩码保留，因此每个操作都必须绑定自己的掩码。

设计要点：`PortableSpeculationIdentity` 把一个指令实例与一个执行域令牌配对。注释解释说，令牌用于区分恰好使用同一范围的不同动态写入者。

<!-- PTO-READER-BLOCK: block-model-state-types-boundaries role=boundaries -->
## 架构边界

`BARG` 没有陷阱字段。`BPC` 不在该记录中；它位于程序控制状态中。

消费者依赖记录把就绪性描述为一个逻辑上所需的单元集合和一个生命周期状态（Waiting、Eligible、Retired、Cancelled）。注释说明它不暴露任何后端队列或物理就绪表。

<!-- PTO-READER-BLOCK: block-model-state-types-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个带有两个源 Tile、一个位于 hand `T` 且带大小码的目标、PE 掩码 `1111` 并设置了 `last` 的 `B.IOT` 填充一个 `BundleTileBinding`。`source0_valid` 和 `source1_valid` 为 true，`destination_valid` 为 true，而 `destination_allocated_by_bundle` 保持为 false，直到提交时分配目标。

<!-- PTO-READER-BLOCK: block-model-state-types-related role=related-owners-navigation -->
## 相关所有者

- [控制状态](control-state.md)声明这些类型的变量。
- [指令束编码](../schema/bundle-encoding.md)把种类和转移映射到它们的编码。
- [Local 代次](../operands/local-generation.md)和 [Shared 代次](../operands/shared-generation.md)使用代次记录。
- [子视图描述符](../operands/subview-descriptor.md)构建 `BundleSubviewDescriptor`。
<!-- SUPPLEMENTARY-END -->

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
    source_count: integer {0..3},
    execution_mask_present: boolean
};

type BundleExecutionMaskCarrier of enumeration {
    BundleExecutionMask_None,
    BundleExecutionMask_GPR,
    BundleExecutionMask_PredicateTile
};

// This is the explicit carrier bound by one selected TileOp. It is pending
// bundle-operand state and never survives commit as an implicit current mask.
type BundleExecutionMaskBinding of record {
    valid: boolean,
    carrier: BundleExecutionMaskCarrier,
    predicate_tile: TileIndex,
    predicate_source_ordinal: integer {0..31},
    low_word: Word,
    high_word: Word,
    word_count: integer {0..2},
    layout: TileLayout,
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    invert: boolean,
    zero_inactive: boolean,
    merge_base_valid: boolean,
    merge_base: TileIndex,
    predicate_tile_snapshot: bits(524288)
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
    pe_mask: bits(4),
    ready: boolean,
    physical_rows: integer {0..65535},
    physical_columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    predicate_basis_type: TileDataType,
    layout: TileLayout,
    identity: PortableSpeculationIdentity
};

type LocalGenerationWriterSnapshot of array [[16]] of LocalGenerationWriter;

type LocalGenerationPECoverageSnapshot of array [[4]] of bits(2048);
type LocalGenerationPEBooleanSnapshot of array [[4]] of boolean;
type LocalGenerationPEDestinationSnapshot of array [[4]] of TileIndex;

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
    participant_mask: bits(4),
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
    predicate_basis_type: TileDataType,
    layout: TileLayout,
    cube_k_repeat: integer {0..65535},
    cube_n_repeat: integer {0..8192},
    cube_cell_count: integer {0..16384},
    cube_storage_bytes: integer {0..262144}
};

type LocalGenerationState of record {
    open: boolean,
    closed: boolean,
    published: boolean,
    generation_identity_valid: boolean,
    descriptor_finalized: boolean,
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
    committed_valid: boolean,
    per_pe_covered_cells: LocalGenerationPECoverageSnapshot,
    per_pe_ready_cells: LocalGenerationPECoverageSnapshot,
    per_pe_closed: LocalGenerationPEBooleanSnapshot,
    per_pe_published: LocalGenerationPEBooleanSnapshot,
    per_pe_working_destination: LocalGenerationPEDestinationSnapshot
};

// The 64 records are the four ordinary relative-generation queues (T/U/M/N),
// sixteen positions per hand.  A record is keyed by its allocated destination
// and carries the independent participating-PE state for one logical parent.
type LocalGenerationSnapshot of array [[64]] of LocalGenerationState;

type SharedGenerationState of record {
    open: boolean,
    closed: boolean,
    published: boolean,
    shared_tile_id: SharedTileID,
    participant_mask: bits(4),
    parent_size_code: integer {0..12},
    parent_cell_count: integer {0..8192},
    covered_cells: bits(8192),
    ready_cells: bits(8192),
    arrived_participants: bits(4),
    specialized_inputs_valid: boolean,
    specialized_input0: Word,
    specialized_input1: Word,
    specialized_input2: Word,
    specialized_input3: Word,
    specialized_metadata: Word,
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
    size_code: integer {0..15},
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
    source0_relative: boolean,
    source1_relative: boolean,
    source0: TileIndex,
    source1: TileIndex,
    parent_ref_valid: boolean,
    parent_ref_relative: boolean,
    parent_ref: TileIndex,
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
    canonicalize: boolean,
    execution_mask_invert: boolean,
    execution_mask_zero: boolean
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
    trans_b: boolean,
    c_scale_en: boolean
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
