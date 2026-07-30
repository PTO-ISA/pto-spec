// PTO-REQ-STATE-001, PTO-REQ-TILE-001, PTO-REQ-FAULT-001,
// PTO-REQ-MEMORY-TSO-001.

type Word of bits(PTO_XLEN);
type DoubleWord of bits(PTO_XLEN * 2);
type HalfWord of bits(32);
type Byte of bits(8);
type GPRIndex of integer {0..PTO_ABSOLUTE_GPR_COUNT-1};
type Reg5Selector of integer {0..31};
type TileIndex of integer {0..PTO_TILE_REGISTER_COUNT-1};
type TemporaryQueueIndex of integer {0..PTO_TEMPORARY_QUEUE_DEPTH-1};
type PredicateIndex of integer {0..PTO_PREDICATE_REGISTER_COUNT-1};
type BlockDimensionIndex of integer {0..PTO_BLOCK_DIMENSION_COUNT-1};
type BlockScalarBindingIndex of integer {0..PTO_BLOCK_SCALAR_BINDING_COUNT-1};
type BlockTileBindingIndex of integer {0..PTO_BLOCK_TILE_BINDING_COUNT-1};
type TileBaseIndex of integer {0..PTO_TILE_BASE_COUNT-1};
type ModelTileElementIndex of integer {0..PTO_MODEL_TILE_ELEMENTS-1};
type ModelAddress of integer {0..PTO_MODEL_MEMORY_BYTES-1};
type SystemRegisterAddress of bits(24);
type SystemRegisterFileIndex of integer {0..65535};
type TrapNumber of bits(6);

type FaultCode of enumeration {
    Fault_None,
    Fault_IllegalInstruction,
    Fault_InstructionPC,
    Fault_InstructionPage,
    Fault_DataAlignment,
    Fault_DataPage,
    Fault_SoftwareBreakpoint,
    Fault_Assert,
    Fault_TileLegality,
    Fault_TileAllocation,
    Fault_BlockControl
};

type BlockKind of enumeration {
    BlockKind_Standard,
    BlockKind_Floating,
    BlockKind_System,
    BlockKind_MachineParallel,
    BlockKind_MachineSequential,
    BlockKind_TileElement,
    BlockKind_TileMemory,
    BlockKind_TileMatrix,
    BlockKind_FrameTemplate
};

type BlockTransfer of enumeration {
    BlockTransfer_Fallthrough,
    BlockTransfer_Direct,
    BlockTransfer_Conditional,
    BlockTransfer_Call,
    BlockTransfer_Return,
    BlockTransfer_Indirect,
    BlockTransfer_IndirectCall
};

// ACR0 is the root ring. The active profile defines permissions and the
// implemented Access Control Ring subtree.
type AccessControlRing of integer {0..15};
type TemporaryQueueSnapshot of array [[PTO_TEMPORARY_QUEUE_DEPTH]] of Word;

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

type FloatingRoundingMode of enumeration {
    FloatingRound_Nearest,
    FloatingRound_Up,
    FloatingRound_Down,
    FloatingRound_TowardsZero,
    FloatingRound_Away
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

// B.DATR Layout identities. NORM is mandatory; every conversion identity is
// capability-gated by block state before it can become active.
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
    TileExecution_Faulted,
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
    flag0: boolean
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
        flag0 = FALSE
    };
end;

type TilePayload of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;

type TileInfo of record {
    allocated: boolean,
    contents_defined: boolean,
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
    block_argument: Word,
    commit_argument: Word,
    block_active: boolean,
    block_body_active: boolean,
    t_queue: TemporaryQueueSnapshot,
    u_queue: TemporaryQueueSnapshot,
    accumulator: AccumulatorState
};
