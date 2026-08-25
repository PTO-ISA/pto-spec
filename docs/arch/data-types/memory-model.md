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

This unit defines the typed records and enumerations used to represent data-access probes, memory orders, memory events, and event relations.

It provides the vocabulary consumed by executable memory owners without itself deciding whether a complete execution is accepted.

<!-- PTO-READER-BLOCK: arch-memory-model-types-concepts-state role=concepts-state -->
## Concepts and visible state

- `DataAccessProbe` pairs a `FaultCode` with the translated `Word` address.
- `MemoryOrder` distinguishes `Relaxed`, `Acquire`, `Release`, and `AcquireRelease`; `MemoryEventKind` distinguishes initial write, load, store, atomic, and fence events.
- A `MemoryEvent` records agent, address, size, read and write values, whether a write occurred, order, reads-from index, coherence rank, and fence predecessor/successor masks.

<!-- PTO-READER-BLOCK: arch-memory-model-types-rules-interactions role=rules-interactions -->
## Rules and interactions

Memory event sizes are limited to `1`, `2`, `4`, or `8` bytes.

Agent IDs, event indices, and coherence ranks are bounded by `PTO_MODEL_MEMORY_AGENTS` and `PTO_MODEL_MEMORY_EVENTS`.

`MemoryRelationMatrix` stores one relation row per modeled event as `bits(PTO_MODEL_MEMORY_EVENTS)`.

<!-- PTO-READER-BLOCK: arch-memory-model-types-boundaries role=boundaries -->
## Architectural boundaries

These declarations describe representation, not ordering acceptance. Program order, reads-from validity, coherence, fences, and cycle rejection are owned by the memory-ordering ASL.

`PTO_MODEL_MEMORY_EVENTS` is a model bound, not a portable maximum event count for hardware.

<!-- PTO-READER-BLOCK: arch-memory-model-types-example-usage role=example-usage -->
## Non-normative reading example

`MemoryEvent_Load` entries carry their source in `read_from`. Events that perform writes carry their `coherence_rank`; the ordering owner validates both fields in the complete relation set.

When debugging a memory result, inspect the event record first, then follow its indices into the matrices built by the ordering owner.

<!-- PTO-READER-BLOCK: arch-memory-model-types-related-owners role=related-owners-navigation -->
## Related owners

- [Memory ordering](../memory-model/ordering.md)
- [Memory operation selectors](memory-operations.md)
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
```
<!-- GENERATED-ASL-END: unit -->
