<!-- GENERATED FROM: asl/tile/model/memory/restart.asl -->
# Restart

**Normative ASL source:** `asl/tile/model/memory/restart.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-RESTART}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-restart-purpose role=purpose-scope -->
## Purpose and scope

This unit contains no executable ASL. Its only content is a comment stating that restart and precise-fault behavior is owned by the memory operations and by the architecture fault model.

It exists as a navigation point. Its dependencies name the two real owners: the Tile atomics unit and the architecture fault-precision unit `PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION`.

<!-- PTO-READER-BLOCK: tile-model-memory-restart-concepts role=concepts-state -->
## Concepts and visible state

This unit declares no state. The state that matters for restart lives elsewhere:

- `_MemoryReplayState` in the fault-precision unit records whether a replay window is active, the request it belongs to, and how many memory events are committed.
- `SetFault` records the fault code in `_LastFault` and the faulting address in `_FaultAddress`, and saves a trap context for the target ring.

A precise fault means that older effects remain, the faulting request is the restart point, and younger work has no architectural effect.

<!-- PTO-READER-BLOCK: tile-model-memory-restart-rules role=rules-interactions -->
## Rules and interactions

The Tile memory bodies follow two restart patterns.

- Stop-at-first-fault: Local `TLOAD` and `TSTORE`, and the Shared transfer helpers, access element by element and stop at the first failing probe. Effects already completed stay visible.
- Probe-all-first: `MGATHER`, `MSCATTER`, their MASK forms, `MGATHER_CAS`, the GM atom/red family, and `TPREFETCHCore` probe every active address before the first memory access or event. A fault in that phase leaves GM and memory events unchanged.

Design point: the fault-precision contract says that retrying a faulting Tile memory request re-executes the whole logical request and never exposes an internal lane or cursor as architectural state. The consequence for software is that a handler fixes the cause, such as mapping a page, and returns to the same request; it cannot resume in the middle.

Design point: a replay flush never rolls back committed GM writes or Tile payload elements. For stop-at-first-fault operations, a retry can therefore write the same GM locations a second time. For probe-all-first operations, no access from the faulting attempt has happened, so a retry starts from unchanged memory.

<!-- PTO-READER-BLOCK: tile-model-memory-restart-boundaries role=boundaries -->
## Architectural boundaries

This unit adds no rule of its own. If a statement here and an owner disagree, the owner wins:

- The fault-precision unit owns the replay record and the flush rules.
- Each memory body owns where it probes and where it stops.
- The block fault and rollback units own release of bundle-allocated destinations after a fault.

<!-- PTO-READER-BLOCK: tile-model-memory-restart-example role=example-usage -->
## Non-normative reading example

A U32 `TSTORE` of a 2 by 4 valid region writes 8 elements in row-major order. Suppose element `(1, 2)`, the seventh element, is on an unmapped page.

- Elements `(0, 0)` through `(1, 1)` are written, 6 x 4 = 24 bytes in total, and their events are committed.
- The probe for `(1, 2)` fails with `Fault_DataPage`, and `(1, 3)` is not attempted.
- After the page is mapped, the retry writes all 8 elements again.

The same fault in a U32 `MSCATTER` is found during the probe phase, so none of its 8 lanes is written before the fault.

<!-- PTO-READER-BLOCK: tile-model-memory-restart-related role=related-owners-navigation -->
## Related owners

- [Fault precision](../../../arch/memory-model/fault-precision.md) owns the replay record and restart contract.
- [Load and store](load-store.md) shows the stop-at-first-fault pattern.
- [Gather and scatter](gather-scatter.md) and [Atomics](atomics.md) show the probe-all-first pattern.
- [Block fault rollback](../../../block/model/faults/rollback.md) owns destination release after a fault.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/restart.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-RESTART","surface":"tile","classification":["model","memory","restart"],"depends_on":["PTO-TILE-MODEL-MEMORY-ATOMICS","PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
// Restart and precise-fault behavior is owned by the memory operations and architecture fault model.
```
<!-- GENERATED-ASL-END: unit -->
