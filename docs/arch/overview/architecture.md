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

PTO is defined here as a 64-bit architecture: `PTO_XLEN` is `64`, and the current architecture identity is version `0`.

This entry point deliberately stays small. It establishes the top-level ownership, state-closure, completion-and-event, tile-capacity, and release-verification contracts while leaving instruction behavior to the reachable ASL owners.

<!-- PTO-READER-BLOCK: arch-overview-concepts-state role=concepts-state -->
## Concepts and visible state

Architecture-visible state is exactly the closed set of named state owners listed below.

- Scalar and control state comprises `PTO-STATE-ARCH-GPR`, `PTO-STATE-ARCH-TEMPORARY-QUEUES`, `PTO-STATE-ARCH-PROGRAM-CONTROL`, and `PTO-STATE-ARCH-FAULT`.
- System state comprises `PTO-STATE-ARCH-MEMORY`, `PTO-STATE-ARCH-MAINTENANCE`, `PTO-STATE-ARCH-SYSTEM-REGISTERS`, `PTO-STATE-ARCH-EXTENDED-SYSTEM-REGISTERS`, `PTO-STATE-ARCH-TRAP-CONTEXT`, and `PTO-STATE-ARCH-GQM`.
- Tile and bundle execution add `PTO-STATE-TILE-LOCAL`, `PTO-STATE-TILE-SHARED`, and `PTO-STATE-BLOCK-CONTROL` to that closed set.

<!-- PTO-READER-BLOCK: arch-overview-rules-interactions role=rules-interactions -->
## Rules and interactions

Current architectural meaning is owned by mnemonic or architecture ASL. Catalogs and Markdown are deterministic projections or evidence, not alternate semantic owners.

Accepted instruction completion and architecture-visible memory events are determined by the reachable dispatch, completion, and memory-event ASL owners.

Every member of the closed state set changes only through an accepted ASL transition owned by the corresponding state unit.

<!-- PTO-READER-BLOCK: arch-overview-boundaries role=boundaries -->
## Architectural boundaries

Local and Shared tile allocations use independent capacity pools. One `B.IOT` Local object may select only `128 B..64 KiB`; multiple Local objects on the same PE may jointly consume that PE's `256 KiB` Local pool. `B.IOS` denotes one Core-wide Shared allocation from a separate `256 KiB` pool.

A release candidate is valid only for the exact commit that passes the pinned ASL model, all independent AVS results, coverage, projection, and release-evidence checks.

<!-- PTO-READER-BLOCK: arch-overview-example-usage role=example-usage -->
## Non-normative reading example

For a state-change question, first locate the state ID in the closed list above, then follow that ID to its ASL owner and the transition that writes it. Use the generated page to read the owner and AVS only to confirm that the modeled transition was exercised.

For a release question, compare every result with the same immutable commit. A passing result from another commit does not establish the candidate described by `PTO-RELEASE-VERIFICATION`.

<!-- PTO-READER-BLOCK: arch-overview-related-owners role=related-owners-navigation -->
## Related owners

- [Execution context](../programming-model/execution-context.md) inventories the principal architectural state and temporary-queue operations.
- [Memory ordering](../memory-model/ordering.md) defines the event relations used to accept or reject a candidate PTO-TSO execution.
- [Reference profile](../profile/reference-profile.md) supplies deterministic profile implementations for profile-defined hooks.
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

constant PTO_ARCHITECTURE_VERSION = 0;
constant PTO_XLEN = 64;
```
<!-- GENERATED-ASL-END: unit -->
