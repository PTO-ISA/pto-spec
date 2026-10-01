<!-- GENERATED FROM: asl/arch/features/shared-tile-state.asl -->
# Shared Tile State

**Normative ASL source:** `asl/arch/features/shared-tile-state.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-SHARED-TILE-STATE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-shared-tile-state-purpose role=purpose-scope -->
## Purpose and scope

`asl/arch/features/shared-tile-state.asl` has two lines: the `PTO-UNIT` metadata comment and a comment stating that the unit owns the named concept and that executable state is defined by its dependencies. The unit contains no executable ASL of its own.

Its declared dependency is `PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS`, which is itself a two-line marker unit, so following this page's own declaration does not arrive at an executable definition.

<!-- PTO-READER-BLOCK: arch-shared-tile-state-concepts role=concepts-state -->
## What the declared chain reaches

Follow the `depends_on` declarations and three marker units stand between this page and the first executable file: `PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS`, `PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS`, and `PTO-ARCH-FEATURES-PREDICATION`. The fourth unit on the chain, `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS`, executes.

- The only executable file on that chain is `asl/arch/programming-model/predicate-registers.asl`.
- It defines `ReadPredicateRegister`, `WritePredicateRegister`, and `PredicateRegisterHasInstructionConsumer` over `_PredicateRegisters`.
- None of the three markers declares a state variable, and the executable unit on the chain declares none either, so the chain reaches no shared-Tile storage.

Design point: this page's `depends_on` names architecture programming-model markers, and a marker contributes identity and navigation only. Reading this page and its declared chain to the end therefore yields predicate registers rather than shared-Tile registers, so a shared-Tile question has to be redirected to another owner surface.

The executable shared-Tile state is declared elsewhere: state `PTO-STATE-TILE-SHARED` has the single member `_SharedTiles`, owned by `PTO-TILE-MODEL-STATE-LOCAL-REGISTERS`, with `var _SharedTiles : SharedTileSnapshot` and `SharedTileSnapshot of array [[PTO_SHARED_TILE_COUNT]] of SharedTileInfo`. Each record carries `descriptor_valid`, `allocation_mask`, `initialized_mask`, `whole_parent_ready`, `published`, and `tile`, and `PTO_SHARED_TILE_COUNT` is `64`.

Design point: the NDF clause for that state, `PTO-REQ-SHARED-TILE-001`, is embedded with the state and not with this marker; it states that shared Tile registers are the core-private state defined by `PTO-STATE-TILE-SHARED`. A change to shared-Tile behavior is therefore validated against that clause and that state owner, while this page carries no clause to change.

<!-- PTO-READER-BLOCK: arch-shared-tile-state-rules role=rules-interactions -->
## How to follow the ownership chain

This unit contributes identity and one dependency edge: the `id` `PTO-ARCH-FEATURES-SHARED-TILE-STATE`, the `surface` `arch`, the `classification` `["features","shared-tile-state"]`, and one `depends_on` entry. It declares no type, function, constant, or variable, so it cannot change a state transition.

The shared-Tile transitions live in `asl/tile/model/state/shared-registers.asl`, for example `SharedTilePublished`, `AtomicUpdateSharedTile`, and `InstallSharedTile`. Those functions are not on this unit's dependency chain, so this page is not their owner.

Design point: the two lines of the owning file carry metadata and an ownership sentence, with no executable statement between them. No behavior can be added here without a change to a unit that owns ASL, and no shared-Tile rule can be verified against this page.

<!-- PTO-READER-BLOCK: arch-shared-tile-state-boundaries role=boundaries -->
## Boundaries

Do not derive allocation, visibility, publication, profile, or lifetime behavior from this marker. Its two lines state ownership and a dependency only, and contain no rule about any of them.

A claim traced to this page cannot be checked against ASL, because the page owns none. Check the state against `PTO-TILE-MODEL-STATE-LOCAL-REGISTERS` and the transitions against the shared-registers owner.

Design point: the only executable state reachable through the declared chain is the predicate register file, which reads and writes `_PredicateRegisters` and reports no instruction consumer. A reader who stops at the end of that chain arrives at predicate state that has nothing to do with shared Tile registers.

<!-- PTO-READER-BLOCK: arch-shared-tile-state-example role=example-usage -->
## Non-normative reading example

To find out what publishes a shared Tile, start at the metadata on this page, follow `depends_on` to `shared-tile-registers.asl`, and continue through `tile-registers.asl`, `predication.asl`, and `predicate-registers.asl`; that path ends in predicate reads and writes, which do not answer the question.

The answer is one surface away: `SharedTileRecord(shared_tile_id)` returns the `SharedTileInfo` record selected by `UInt(shared_tile_id)`, `SharedTileFullyInitialized` combines `descriptor_valid`, `initialized_mask == allocation_mask`, and `tile.contents_defined`, and `SharedTilePublished` adds `whole_parent_ready` and `published`.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-shared-tile-state-related role=related-owners-navigation -->
## Related owners

- [Shared tile registers](../programming-model/shared-tile-registers.md) is the dependency declared on this page.
- [Tile registers](../programming-model/tile-registers.md) is the next marker in the chain.
- [Shared Tile state and transitions](../../tile/model/state/shared-registers.md) owns `_SharedTiles` access and update.
- [Shared Tile state types](../../tile/model/state/types.md) defines `SharedTileInfo` and `SharedTileSnapshot`.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/shared-tile-state.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-SHARED-TILE-STATE","surface":"arch","classification":["features","shared-tile-state"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SHARED-TILE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
