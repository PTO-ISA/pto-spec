<!-- GENERATED FROM: asl/arch/data-types/memory-model.asl -->
# Memory Model

**Normative ASL source:** `asl/arch/data-types/memory-model.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-MEMORY-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-model-types-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines the typed records and enumerations used to represent data-access probes, memory orders, memory events, and the replay state of a memory request.

It provides the vocabulary that executable memory owners consume, and it does not itself decide whether a complete execution is accepted.

<!-- PTO-READER-BLOCK: arch-memory-model-types-concepts-state role=concepts-state -->
## Concepts and visible state

`DataAccessProbe` pairs a `FaultCode` with the translated `Word` address, and `MemoryReplayState` records whether a replay is active, the request word, the committed event count, and an epoch.

`MemoryOrder` distinguishes `MemoryOrder_Relaxed`, `MemoryOrder_Acquire`, `MemoryOrder_Release`, and `MemoryOrder_AcquireRelease`; `MemoryEventKind` distinguishes `MemoryEvent_InitialWrite`, `MemoryEvent_Load`, `MemoryEvent_Store`, `MemoryEvent_Atomic`, and `MemoryEvent_Fence`.

A `MemoryEvent` records the kind, the agent, the address, the access size, the read and write values, whether a write was performed, the order, the reads-from event index, the coherence rank, and the fence predecessor and successor masks.

<!-- PTO-READER-BLOCK: arch-memory-model-types-rules-interactions role=rules-interactions -->
## Rules and interactions

Design point: a load and a store carry both a read value and a write value field, so one record shape can express a load that reads, a store that writes, and an atomic that does both without three separate records.

Memory event sizes are limited to `1`, `2`, `4`, or `8` bytes, so a modeled access always has one of four widths.

`MemoryShareability` separates `MemoryShareability_Private`, `MemoryShareability_IntraCore`, and `MemoryShareability_InterCore`, and `MemoryFenceStrength` derives no, release, acquire, or acquire-release strength from a mask pair.

<!-- PTO-READER-BLOCK: arch-memory-model-types-boundaries role=boundaries -->
## Architectural boundaries

Agent IDs, event indices, and coherence ranks are bounded by `PTO_MODEL_MEMORY_AGENTS` and `PTO_MODEL_MEMORY_EVENTS`, and `MemoryRelationMatrix` stores one row per modeled event as `bits(PTO_MODEL_MEMORY_EVENTS)`.

Design point: shareability is stated as an architecture-visible classification rather than a cache or interconnect tier, so a consumer reasons about who observes an access instead of about a particular memory hierarchy.

This unit declares types and no functions, so nothing here is evaluated at run time: the check that accepts or rejects a complete execution is owned by the memory-ordering unit.

<!-- PTO-READER-BLOCK: arch-memory-model-types-example-usage role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

These declarations describe representation, not ordering acceptance; program order, reads-from validity, coherence, fences, and cycle rejection belong to the memory-ordering ASL.

A `MemoryReplayState` with `active` false is the state left after a replay ends, so a consumer must not read the replay window as still in progress.

<!-- PTO-READER-BLOCK: arch-memory-model-types-related-owners role=related-owners-navigation -->
## Related owners

- [Memory ordering](../memory-model/ordering.md) consumes these event records.

- [Memory operation selectors](memory-operations.md) names the atomic and address-update selectors.

- [Integer types](integer.md) defines `Word`, the address carrier these records use.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/memory-model.asl -->
```asl
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

type MemoryReplayState of record {
    active: boolean,
    request: Word,
    committed_event_count: integer {0..PTO_MODEL_MEMORY_EVENTS},
    epoch: integer
};
```
<!-- GENERATED-ASL-END: unit -->
