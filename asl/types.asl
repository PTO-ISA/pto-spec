// PTO-REQ-STATE-001, PTO-REQ-TILE-001, PTO-REQ-FAULT-001,
// PTO-REQ-MEMORY-TSO-001.

type Word of bits(PTO_XLEN);
type DoubleWord of bits(PTO_XLEN * 2);
type HalfWord of bits(32);
type Byte of bits(8);
type GPRIndex of integer {0..23};
type Reg5Selector of integer {0..31};
type TileIndex of integer {0..63};
type PipeIndex of integer {0..PTO_PIPE_COUNT-1};
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
    Fault_TileLegality
};

type PrivilegeLevel of enumeration {
    Privilege_User,
    Privilege_Supervisor,
    Privilege_Machine
};

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
    SystemRegister_TP,
    SystemRegister_GP,
    SystemRegister_TIME,
    SystemRegister_CSTATE,
    SystemRegister_CORE_ID,
    SystemRegister_VENDOR,
    SystemRegister_VERSION,
    SystemRegister_CORE_FEATURE,
    SystemRegister_CORE_FEATURE_ENABLE,
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
    TileDataType_S8,
    TileDataType_U8,
    TileDataType_S16,
    TileDataType_U16,
    TileDataType_S32,
    TileDataType_U32,
    TileDataType_S64,
    TileDataType_U64,
    TileDataType_F16,
    TileDataType_BF16,
    TileDataType_F32,
    TileDataType_FP8,
    TileDataType_FP4,
    TileDataType_E8M0
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
    pipe: PipeIndex,
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
        pipe = 0,
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

type TileState of record {
    allocated: boolean,
    capacity_bytes: integer {0..524288},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    location: TileLocation,
    payload: TilePayload
};

type PipeSlots of array [[PTO_MODEL_PIPE_DEPTH]] of TileState;
type PipeState of record {
    configured: boolean,
    base_address: Word,
    slot_size_bytes: integer {1..262144},
    slot_count: integer {1..PTO_MODEL_PIPE_DEPTH},
    head: integer {0..PTO_MODEL_PIPE_DEPTH-1},
    tail: integer {0..PTO_MODEL_PIPE_DEPTH-1},
    count: integer {0..PTO_MODEL_PIPE_DEPTH},
    producer_claimed: boolean,
    consumer_claimed: boolean,
    producer_slot: integer {0..PTO_MODEL_PIPE_DEPTH-1},
    consumer_slot: integer {0..PTO_MODEL_PIPE_DEPTH-1},
    slots: PipeSlots
};
