// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-MEMORY-MODEL","surface":"arch","classification":["data-types","memory-model"],"depends_on":["PTO-BLOCK-MODEL-STATE-TYPES"]}
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

// Shareability is an architecture-visible classification used by the memory
// model.  It is deliberately independent of any cache or interconnect tier.
type MemoryShareability of enumeration {
    MemoryShareability_Private,
    MemoryShareability_IntraCore,
    MemoryShareability_InterCore
};

// Fences carry their predecessor/successor class masks as the portable
// transport contract.  Strength is derived from the pair of masks rather than
// from an implementation-specific opcode encoding.
type MemoryFenceStrength of enumeration {
    MemoryFenceStrength_None,
    MemoryFenceStrength_Release,
    MemoryFenceStrength_Acquire,
    MemoryFenceStrength_AcquireRelease
};

type MemoryAgentId of integer {0..PTO_MODEL_MEMORY_AGENTS-1};
type MemoryEventOrigin of enumeration {
    MemoryEventOrigin_NonKernel,
    MemoryEventOrigin_Kernel,
    MemoryEventOrigin_Handler
};
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
    active: boolean,
    committed: boolean,
    replay_epoch: integer,
    kind: MemoryEventKind,
    core_identity: PTOModelCoreIdentity,
    agent: MemoryAgentId,
    origin: MemoryEventOrigin,
    invocation: integer,
    program_order: integer,
    collective_epoch: integer,
    collective_history_sequence: integer,
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

type MemoryReplayState of record {
    active: boolean,
    request: Word,
    committed_event_count: integer {0..PTO_MODEL_MEMORY_EVENTS},
    epoch: integer,
    owner_core: PTOModelCoreIdentity,
    owner_agent: MemoryAgentId,
    owner_origin: MemoryEventOrigin,
    owner_invocation: integer,
    owner_program_order: integer
};
