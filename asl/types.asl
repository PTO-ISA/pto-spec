// PTO-REQ-STATE-001, PTO-REQ-TILE-001, PTO-REQ-FAULT-001,
// PTO-REQ-MEMORY-TSO-001.

type Word of bits(PTO_XLEN);
type DoubleWord of bits(PTO_XLEN * 2);
type HalfWord of bits(32);
type Byte of bits(8);
type PredicateWord of bits(PTO_PREDICATE_WIDTH);
type GPRIndex of integer {0..PTO_ABSOLUTE_GPR_COUNT-1};
type Reg5Selector of integer {0..31};
type TileIndex of integer {0..PTO_TILE_REGISTER_COUNT-1};
type TemporaryQueueIndex of integer {0..PTO_TEMPORARY_QUEUE_DEPTH-1};
type PredicateIndex of integer {0..PTO_PREDICATE_REGISTER_COUNT-1};
type BundleDimensionIndex of integer {0..PTO_BUNDLE_DIMENSION_COUNT-1};
type BundleScalarBindingIndex of integer {0..PTO_BUNDLE_SCALAR_BINDING_COUNT-1};
type BundleTileBindingIndex of integer {0..PTO_BUNDLE_TILE_BINDING_COUNT-1};
type TileBaseIndex of integer {0..PTO_TILE_BASE_COUNT-1};
type ModelTileElementIndex of integer {0..PTO_MODEL_TILE_ELEMENTS-1};
type ModelAddress of integer {0..PTO_MODEL_MEMORY_BYTES-1};
type SystemRegisterAddress of bits(24);
type SystemRegisterFileIndex of integer {0..65535};
type TrapNumber of bits(6);
type InterruptID of integer {0..63};

type FaultCode of enumeration {
    Fault_None,
    Fault_ExecutionStateCheck,
    Fault_IllegalInstruction,
    Fault_InstructionPC,
    Fault_InstructionPage,
    Fault_DataAlignment,
    Fault_DataPage,
    Fault_SoftwareBreakpoint,
    Fault_HardwareBreakpoint,
    Fault_HardwareWatchpoint,
    Fault_Assert,
    Fault_TileLegality,
    Fault_TileAllocation,
    Fault_BundleControl,
    Fault_ServiceRequest
};

type BundleKind of enumeration {
    BundleKind_Standard,
    BundleKind_Floating,
    BundleKind_System,
    BundleKind_MachineParallel,
    BundleKind_MachineSequential,
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

// A bundle start always installs one descriptor. Control-only starts retain
// their exact form and modifiers, while operation-bearing starts additionally
// carry the selector consumed when the bundle is committed.
// PTO-REQ-BUNDLE-OPERATION-001: exact start fields survive decode and commit.
type BundleOperationClass of enumeration {
    BundleOperation_Control,
    BundleOperation_Machine,
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
    source0_valid: boolean,
    source1_valid: boolean,
    source0: TileIndex,
    source1: TileIndex,
    source0_reuse: boolean,
    source1_reuse: boolean,
    last: boolean
};

type BundleControlAttributes of record {
    trap_enabled: boolean,
    atomic: boolean,
    acquire: boolean,
    release: boolean,
    far: boolean,
    direct_register: boolean
};

type BundleDataAttributes of record {
    data_type: bits(5),
    data_layout: bits(5),
    pad_value: bits(2),
    conversion_mode: bits(3),
    rounding_mode: bits(3),
    saturating: boolean,
    canonicalize: boolean
};

// ACR0 is the root ring. The active profile defines permissions and the
// implemented Access Control Ring subtree.
type AccessControlRing of integer {0..15};
type TemporaryQueueSnapshot of array [[PTO_TEMPORARY_QUEUE_DEPTH]] of Word;
type PredicateSnapshot of array [[PTO_PREDICATE_REGISTER_COUNT]]
    of PredicateWord;
type BundleDimensionSnapshot of array [[PTO_BUNDLE_DIMENSION_COUNT]] of Word;
type BundleScalarBindingSnapshot of array [[PTO_BUNDLE_SCALAR_BINDING_COUNT]]
    of BundleScalarBinding;
type BundleTileBindingSnapshot of array [[PTO_BUNDLE_TILE_BINDING_COUNT]]
    of BundleTileBinding;

type DataAccessProbe of record {
    fault: FaultCode,
    translated_address: Word
};

type MemoryOrder of enumeration {
    MemoryOrder_Relaxed,
    MemoryOrder_Acquire,
    MemoryOrder_Release,
    MemoryOrder_AcquireRelease
};

type MemoryAgentId of integer {0..PTO_MODEL_MEMORY_AGENTS-1};
type MemoryEventIndex of integer {0..PTO_MODEL_MEMORY_EVENTS-1};
type MemoryCoherenceRank of integer {0..PTO_MODEL_MEMORY_EVENTS-1};

type MemoryEventKind of enumeration {
    MemoryEvent_InitialWrite,
    MemoryEvent_Load,
    MemoryEvent_Store,
    MemoryEvent_Atomic,
    MemoryEvent_Fence
};

type MemoryEvent of record {
    kind: MemoryEventKind,
    agent: MemoryAgentId,
    address: Word,
    size_bytes: integer {1,2,4,8},
    read_value: Word,
    write_value: Word,
    write_performed: boolean,
    order: MemoryOrder,
    read_from: MemoryEventIndex,
    coherence_rank: MemoryCoherenceRank,
    fence_predecessor: bits(4),
    fence_successor: bits(4)
};

type MemoryRelationMatrix of array [[PTO_MODEL_MEMORY_EVENTS]]
    of bits(PTO_MODEL_MEMORY_EVENTS);

type AddressUpdateMode of enumeration {
    AddressUpdate_None,
    AddressUpdate_PreIndex,
    AddressUpdate_PostIndex
};

type AtomicOperation of enumeration {
    Atomic_SWAP,
    Atomic_ADD,
    Atomic_AND,
    Atomic_OR,
    Atomic_XOR,
    Atomic_SMIN,
    Atomic_SMAX,
    Atomic_UMIN,
    Atomic_UMAX
};

type SystemRegister of enumeration {
    SystemRegister_THREAD_PTR,
    SystemRegister_GLOBAL_PTR,
    SystemRegister_TIME,
    SystemRegister_CORE_STATE,
    SystemRegister_CORE_ID,
    SystemRegister_THREAD_ID,
    SystemRegister_VENDOR,
    SystemRegister_VERSION,
    SystemRegister_CORE_FEATURE,
    SystemRegister_CORE_FEATURE_ENABLE,
    SystemRegister_TILE_CAPACITY,
    SystemRegister_BLOCKNUM,
    SystemRegister_BLOCKID,
    SystemRegister_CYCLE
};

type SystemRegisterAccess of enumeration {
    SystemRegisterAccess_Unknown,
    SystemRegisterAccess_ReadOnly,
    SystemRegisterAccess_WriteOnly,
    SystemRegisterAccess_ReadWrite
};

type MaintenanceOperation of enumeration {
    Maintenance_DC_IALL,
    Maintenance_DC_IVA,
    Maintenance_DC_ISW,
    Maintenance_DC_ZVA,
    Maintenance_DC_CVA,
    Maintenance_DC_CIVA,
    Maintenance_DC_CSW,
    Maintenance_DC_CISW,
    Maintenance_IC_IALL,
    Maintenance_IC_IVA,
    Maintenance_BC_IALL,
    Maintenance_BC_IVA,
    Maintenance_TLB_IV,
    Maintenance_TLB_IAV,
    Maintenance_TLB_IA,
    Maintenance_TLB_IALL
};

type FloatingBinaryOperation of enumeration {
    FloatingBinary_ADD,
    FloatingBinary_SUB,
    FloatingBinary_MUL,
    FloatingBinary_DIV,
    FloatingBinary_MIN,
    FloatingBinary_MAX
};

type FloatingCompareOperation of enumeration {
    FloatingCompare_EQ,
    FloatingCompare_NE,
    FloatingCompare_LT,
    FloatingCompare_LE,
    FloatingCompare_GT,
    FloatingCompare_GE
};

type FloatingUnaryOperation of enumeration {
    FloatingUnary_ABS,
    FloatingUnary_SQRT,
    FloatingUnary_EXP,
    FloatingUnary_RECIP
};

type FloatingFusedOperation of enumeration {
    FloatingFused_MADD,
    FloatingFused_MSUB,
    FloatingFused_NMADD,
    FloatingFused_NMSUB
};

// Semantic rounding modes are independent of every encoded selector
// namespace. Scalar FRM, fixed conversion overrides, bundle RMode, and public
// API controls must resolve into this type explicitly.
type NumericRoundingMode of enumeration {
    NumericRound_RNE,
    NumericRound_RTM,
    NumericRound_RTP,
    NumericRound_RTZ,
    NumericRound_RNA,
    NumericRound_RTO,
    NumericRound_RHB
};

type NumericExecutionControl of record {
    rounding_mode: NumericRoundingMode,
    saturating: boolean
};

type TileNumericSelection of record {
    use_operation_default: boolean,
    rounding_mode: NumericRoundingMode,
    saturating: boolean
};

pure func DefaultNumericExecutionControl() => NumericExecutionControl
begin
    return NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
end;

// Selects only a bounded set of accepted negative applicability rules. This
// is not a complete target-profile selector: absence of a rejection does not
// claim target support or select numeric result semantics.
type NumericApplicabilityRuleSet of enumeration {
    NumericApplicabilityRules_None,
    NumericApplicabilityRules_A2A3MxRejection
};

type TileHand of enumeration {
    TileHand_T,
    TileHand_U,
    TileHand_M,
    TileHand_N
};

type TileDataType of enumeration {
    TileDataType_FP64,
    TileDataType_FP32,
    TileDataType_TF32,
    TileDataType_HF32,
    TileDataType_FP16,
    TileDataType_BF16,
    TileDataType_HiF8,
    TileDataType_E4M3,
    TileDataType_E5M2,
    TileDataType_E3M2,
    TileDataType_E2M3,
    TileDataType_E2M1X2,
    TileDataType_E1M2X2,
    TileDataType_E8M0,
    TileDataType_HiF4X2,
    TileDataType_S64,
    TileDataType_S32,
    TileDataType_S16,
    TileDataType_S8,
    TileDataType_S4X2,
    TileDataType_U64,
    TileDataType_U32,
    TileDataType_U16,
    TileDataType_U8,
    TileDataType_U4X2
};

type TileDataLayout of enumeration {
    TileDataLayout_NORM,
    TileDataLayout_ND2DN,
    TileDataLayout_ND2ZN,
    TileDataLayout_ND2NZ,
    TileDataLayout_DN2ND,
    TileDataLayout_DN2ZN,
    TileDataLayout_DN2NZ,
    TileDataLayout_ZN2ND,
    TileDataLayout_ZN2DN,
    TileDataLayout_ZN2NZ,
    TileDataLayout_NZ2ND,
    TileDataLayout_NZ2DN,
    TileDataLayout_NZ2ZN
};

type TilePadValue of enumeration {
    TilePad_Zero,
    TilePad_Max,
    TilePad_Min,
    TilePad_Null
};

type TileLayout of enumeration {
    TileLayout_RowMajor,
    TileLayout_ColumnMajor,
    TileLayout_ImplementationDefined
};

type TileLocation of enumeration {
    TileLocation_Vector,
    TileLocation_Matrix,
    TileLocation_Memory,
    TileLocation_Any
};

type ScalarBinaryOperation of enumeration {
    ScalarBinary_ADD,
    ScalarBinary_SUB,
    ScalarBinary_AND,
    ScalarBinary_OR,
    ScalarBinary_XOR,
    ScalarBinary_SLL,
    ScalarBinary_SRL,
    ScalarBinary_SRA,
    ScalarBinary_MIN,
    ScalarBinary_MINU,
    ScalarBinary_MAX,
    ScalarBinary_MAXU
};

type ScalarRightModifier of enumeration {
    ScalarRight_None,
    ScalarRight_SignedWord,
    ScalarRight_UnsignedWord,
    ScalarRight_NegateOrNot
};

type ExecutionControlRequest of enumeration {
    ExecutionControl_SendEvent,
    ExecutionControl_WaitEvent,
    ExecutionControl_WaitInterrupt,
    ExecutionControl_WaitTimeout
};

type ScalarCondition of enumeration {
    ScalarCondition_EQ,
    ScalarCondition_NE,
    ScalarCondition_LT,
    ScalarCondition_GE,
    ScalarCondition_LTU,
    ScalarCondition_GEU,
    ScalarCondition_Z,
    ScalarCondition_NZ
};

type TileBinaryOperation of enumeration {
    TileBinary_ADD,
    TileBinary_SUB,
    TileBinary_MUL,
    TileBinary_MAX,
    TileBinary_MIN,
    TileBinary_AND,
    TileBinary_OR,
    TileBinary_XOR,
    TileBinary_SHL,
    TileBinary_SHR,
    TileBinary_DIV,
    TileBinary_REM
};

type TileUnaryOperation of enumeration {
    TileUnary_ABS,
    TileUnary_NOT,
    TileUnary_NEG,
    TileUnary_RELU,
    TileUnary_SQRT,
    TileUnary_LOG,
    TileUnary_RECIP,
    TileUnary_EXP,
    TileUnary_RSQRT
};

type TilePartialOperation of enumeration {
    TilePartial_ADD,
    TilePartial_MUL,
    TilePartial_MAX,
    TilePartial_MIN,
    TilePartial_ARGMAX,
    TilePartial_ARGMIN
};

type TileComparison of enumeration {
    TileComparison_EQ,
    TileComparison_NE,
    TileComparison_LT,
    TileComparison_LE,
    TileComparison_GT,
    TileComparison_GE
};

type TileAxis of enumeration {
    TileAxis_Row,
    TileAxis_Column
};

type TileReductionOperation of enumeration {
    TileReduction_SUM,
    TileReduction_PRODUCT,
    TileReduction_MIN,
    TileReduction_MAX,
    TileReduction_ARGMIN,
    TileReduction_ARGMAX
};

type TileExpandOperation of enumeration {
    TileExpand_COPY,
    TileExpand_ADD,
    TileExpand_SUB,
    TileExpand_MUL,
    TileExpand_DIV,
    TileExpand_MAX,
    TileExpand_MIN,
    TileExpand_EXPDIF
};

type TileExecutionStatus of enumeration {
    TileExecution_Executed,
    TileExecution_Rejected
};

// Uniform decoded operand carrier for direct tile instructions. Catalog
// bindings select only the fields named by each operation; unused fields have
// no architectural effect.
type TileInstructionOperands of record {
    destination0: TileIndex,
    destination1: TileIndex,
    source0: TileIndex,
    source1: TileIndex,
    source2: TileIndex,
    source3: TileIndex,
    source4: TileIndex,
    address: Word,
    scalar0: Word,
    scalar1: Word,
    natural0: integer {0..65535},
    natural1: integer {0..65535},
    positive0: integer {1..65535},
    positive1: integer {1..65535},
    positive2: integer {1..65535},
    positive3: integer {1..65535},
    diagonal: integer {-65535..65535},
    byte_count: integer {0..262144},
    selected_byte: integer {0..3},
    axis: TileAxis,
    comparison: TileComparison,
    flag0: boolean,
    numeric_control: TileNumericSelection
};

pure func DefaultTileInstructionOperands() => TileInstructionOperands
begin
    return TileInstructionOperands {
        destination0 = 0,
        destination1 = 0,
        source0 = 0,
        source1 = 0,
        source2 = 0,
        source3 = 0,
        source4 = 0,
        address = Zeros{PTO_XLEN},
        scalar0 = Zeros{PTO_XLEN},
        scalar1 = Zeros{PTO_XLEN},
        natural0 = 0,
        natural1 = 0,
        positive0 = 1,
        positive1 = 1,
        positive2 = 1,
        positive3 = 1,
        diagonal = 0,
        byte_count = 0,
        selected_byte = 0,
        axis = TileAxis_Row,
        comparison = TileComparison_EQ,
        flag0 = FALSE,
        numeric_control = TileNumericSelection {
            use_operation_default = TRUE,
            rounding_mode = NumericRound_RNE,
            saturating = FALSE
        }
    };
end;

type TilePayload of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;

type TileInfo of record {
    allocated: boolean,
    contents_defined: boolean,
    defined_elements: bits(PTO_MODEL_TILE_ELEMENTS),
    defined_valid_elements: integer {0..4096},
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    location: TileLocation,
    payload: TilePayload
};

type AccumulatorState of record {
    live: boolean,
    logical_data_type: TileDataType,
    info: TileInfo
};

type TrapContext of record {
    valid: boolean,
    source_acr: AccessControlRing,
    tpc: Word,
    bpc: Word,
    core_state: Word,
    bundle_argument: Word,
    commit_argument: Word,
    bundle_active: boolean,
    bundle_body_active: boolean,
    bundle_kind: BundleKind,
    bundle_transfer: BundleTransfer,
    bundle_condition: boolean,
    bundle_target: Word,
    bundle_fallthrough: Word,
    bundle_return_target: Word,
    bundle_body_address: Word,
    bundle_operation: BundleOperationDescriptor,
    bundle_dimensions: BundleDimensionSnapshot,
    bundle_scalar_bindings: BundleScalarBindingSnapshot,
    bundle_tile_bindings: BundleTileBindingSnapshot,
    bundle_control_attributes: BundleControlAttributes,
    bundle_data_attributes: BundleDataAttributes,
    t_queue: TemporaryQueueSnapshot,
    u_queue: TemporaryQueueSnapshot,
    execution_mask: Word,
    predicates: PredicateSnapshot,
    accumulator: AccumulatorState
};
