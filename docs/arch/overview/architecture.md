<!-- GENERATED FROM: asl/arch/overview/architecture.asl -->
# Architecture

**Normative ASL source:** `asl/arch/overview/architecture.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-OVERVIEW-ARCHITECTURE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-overview-purpose-scope role=purpose-scope -->
## Purpose and scope

PTO is a 64-bit instruction set architecture: the constant `PTO_XLEN` is `64`, so every scalar register and every `Word` is 64 bits wide. PTO combines three instruction surfaces, scalar instructions, block (bundle) instructions, and direct Tile operations, and all of them update one shared set of architecture-visible state.

This page is the entry point. It fixes five top-level contracts: who owns architectural meaning, which state is visible, how completion and memory events are defined, how Tile capacity is divided, and what makes a release candidate valid. Instruction behavior itself lives in the per-instruction ASL owners.

The architecture version is not written in ASL. It is the release version recorded in `specification.toml` under `[release].architecture_version`, so the normative ASL stays version neutral.

<!-- PTO-READER-BLOCK: arch-overview-concepts-state role=concepts-state -->
## Concepts and visible state

Architecture-visible state is exactly the closed set of thirteen named state owners listed below. Each ID names one ASL state unit and the variables it owns.

- Scalar and control state comprises `PTO-STATE-ARCH-GPR`, `PTO-STATE-ARCH-TEMPORARY-QUEUES`, `PTO-STATE-ARCH-PROGRAM-CONTROL`, and `PTO-STATE-ARCH-FAULT`.
- System state comprises `PTO-STATE-ARCH-MEMORY`, `PTO-STATE-ARCH-MAINTENANCE`, `PTO-STATE-ARCH-SYSTEM-REGISTERS`, `PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS`, `PTO-STATE-ARCH-TRAP-CONTEXT`, and `PTO-STATE-ARCH-GQM`.
- Tile and bundle execution add `PTO-STATE-TILE-LOCAL`, `PTO-STATE-TILE-SHARED`, and `PTO-STATE-BLOCK-CONTROL` to that closed set.

Design point: the set is closed, and every member changes only through an accepted ASL transition owned by its state unit. Any other storage an implementation uses, such as pipeline buffers or implementation caches, is not architecture-visible, so a correct program cannot observe or depend on it.

<!-- PTO-READER-BLOCK: arch-overview-rules-interactions role=rules-interactions -->
## Rules and interactions

Current architectural meaning is owned by mnemonic ASL or architecture ASL. Catalogs and Markdown pages, including this reader guide, are deterministic projections or evidence, not alternate semantic owners.

Design point: there is exactly one semantic owner for each fact. If a catalog row or a Markdown sentence disagrees with the ASL, the ASL wins, and the projection is the thing to fix. This keeps generated tables and pages from drifting into a second, conflicting definition.

Accepted instruction completion and architecture-visible memory events are defined by the reachable ASL dispatch, completion, and memory-event owners. A reader who wants to know when an instruction has completed, or which memory events it produced, follows those owners rather than an instruction page summary.

<!-- PTO-READER-BLOCK: arch-overview-boundaries role=boundaries -->
## Architectural boundaries

Tile storage has two independent capacity pools. Each PE has its own `256 KiB` Local pool, and the Core has one separate `256 KiB` Shared pool. One `B.IOT` SizeCode describes one selected PE's Local allocation and may select only `128 B..64 KiB`; several Local objects on the same PE may together use that PE's pool. One `B.IOS` SizeCode describes one complete Core-wide Shared allocation.

Design point: Local and Shared allocations must not consume one combined budget. A Shared allocation therefore never reduces the Local capacity available on any PE, and Local allocations never reduce the Shared pool. A program can size its Local working set and its Shared data independently.

A release candidate is valid only as one exact commit that passes the pinned ASL model, every independent AVS result, coverage, projection, and release-evidence checks.

<!-- PTO-READER-BLOCK: arch-overview-example-usage role=example-usage -->
## Non-normative reading example

For a state-change question, first locate the state ID in the closed list above, then follow that ID to its ASL owner and the transition that writes it. Use the generated page to read the owner and AVS only to confirm that the modeled transition was exercised.

For a capacity question, a `B.IOT` destination with SizeCode `10` (`64 KiB`) and all four PEs selected uses `64 KiB` of each selected PE's Local pool. It uses nothing from the Shared pool.

For a release question, compare every result with the same immutable commit. A passing result from another commit does not establish the candidate described by `PTO-RELEASE-VERIFICATION`.

<!-- PTO-READER-BLOCK: arch-overview-related-owners role=related-owners-navigation -->
## Related owners

- [Execution context](../programming-model/execution-context.md) inventories the principal architectural state and temporary-queue operations.
- [Tile allocation](../features/tile-allocation.md) declares the cell size, pool size, and per-object caps behind the capacity contract.
- [Memory ordering](../memory-model/ordering.md) defines the event relations used to accept or reject a candidate PTO-RC execution with preserved Store-to-Store order.
- [Trap context](../state/trap-context.md) and [scalar floating point](../../scalar/model/fsu/scalar-fp.md) supply the deterministic hook implementations.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/overview/architecture.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-OVERVIEW-ARCHITECTURE","surface":"arch","classification":["overview","architecture"],"depends_on":[]}
// PTO Instruction Set Architecture ASL1 entry point.
//
// The Makefile assembles the normative sources in dependency order. This file
// intentionally contains only the architecture identity and top-level contract.

// NDF-BEGIN: PTO-SOURCE-HIERARCHY
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Current architecture contracts MUST be owned by mnemonic or architecture ASL;
// catalogs and Markdown MUST remain deterministic projections or evidence.
// NDF-END: PTO-SOURCE-HIERARCHY

// NDF-BEGIN: PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Accepted instruction completion and its architecture-visible memory events
// MUST be defined by the reachable ASL dispatch, completion, and memory-event owners.
// NDF-END: PTO-ARCH-COMMIT-EVENT-CONFORMANCE-001

// NDF-BEGIN: PTO-ARCH-STATE-CLOSURE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// Architecture-visible state MUST be exactly [[PTO-STATE-ARCH-GPR]],
// [[PTO-STATE-ARCH-TEMPORARY-QUEUES]], [[PTO-STATE-ARCH-PROGRAM-CONTROL]],
// [[PTO-STATE-ARCH-FAULT]], [[PTO-STATE-ARCH-MEMORY]],
// [[PTO-STATE-ARCH-MAINTENANCE]], [[PTO-STATE-ARCH-SYSTEM-REGISTERS]],
// [[PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS]],
// [[PTO-STATE-ARCH-TRAP-CONTEXT]], [[PTO-STATE-TILE-LOCAL]],
// [[PTO-STATE-TILE-SHARED]], [[PTO-STATE-ARCH-GQM]], and
// [[PTO-STATE-BLOCK-CONTROL]], and MUST change only through the accepted ASL
// transitions owned by those state units.
// NDF-END: PTO-ARCH-STATE-CLOSURE-001

// NDF-BEGIN: PTO-TILE-CAPACITY-PER-PE
// ndf: kind=contract level=L1 layer=tile status=accepted
// B.IOT SizeCode MUST denote one selected PE's Local allocation in that PE's
// independent 256 KiB pool. B.IOS SizeCode MUST denote one complete Core-wide
// Shared allocation in the independent 256 KiB Shared pool. Local and Shared
// allocations MUST NOT consume one combined budget.
// NDF-END: PTO-TILE-CAPACITY-PER-PE

// NDF-BEGIN: PTO-RELEASE-VERIFICATION
// ndf: kind=mechanism level=L2 layer=architecture status=accepted
// A release candidate MUST be the exact commit that passes the pinned ASL model,
// every independent AVS result, coverage, projections, and release-evidence checks.
// NDF-END: PTO-RELEASE-VERIFICATION

// The architecture identity is the release architecture version owned by
// specification.toml ([release].architecture_version). Normative ASL remains
// release-version neutral, so this unit declares no version literal.
constant PTO_XLEN = 64;
```
<!-- GENERATED-ASL-END: unit -->
