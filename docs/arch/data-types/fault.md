<!-- GENERATED FROM: asl/arch/data-types/fault.asl -->
# Fault

**Normative ASL source:** `asl/arch/data-types/fault.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-FAULT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-fault-purpose role=purpose-scope -->
## Purpose and scope

`FaultCode` is the PTO ASL enumeration of fault identities, with `Fault_None` plus fifteen named non-`None` members. This unit defines those identities only; it does not define when one is selected or what state transition follows.

The fifteen non-`None` members name an execution-state check, an illegal instruction, an instruction address or instruction page, a data alignment or data page, a hardware or software breakpoint, a hardware watchpoint, an assertion, Tile legality and Tile allocation, bundle control and bundle post-commit, and a service request.

<!-- PTO-READER-BLOCK: arch-fault-concepts role=concepts-state -->
## Concepts and visible state

Each `FaultCode` value is exactly one member of the enumeration, so a consumer cannot express a fault that combines two causes in one value.

The declared members carry no trap number, no priority, no argument, and no recovery behavior; those belong to the ASL owner that raises the fault and to the trap machinery that handles it.

Design point: a fault identity is separated from the trap that reports it, so the same `FaultCode` can be raised by several instructions and reported through one trap entry without either side redefining the other.

<!-- PTO-READER-BLOCK: arch-fault-rules role=rules-interactions -->
## Rules and interactions

`Fault_BundleControl` and `Fault_BundlePostCommit` are distinct members, so a bundle rejected by its control checks is distinguishable from a successfully committed bundle that requests a trap at its commit boundary.

`Fault_TileLegality` and `Fault_TileAllocation` are also distinct members, so a consumer can tell an operand that fails its descriptor or type checks from a destination request that the allocation cannot satisfy.

`Fault_None` is itself a member, so a value of this type always has an answer and no separate absence representation is needed.

<!-- PTO-READER-BLOCK: arch-fault-boundaries role=boundaries -->
## Architectural boundaries

This unit declares no behavior of its own, so a `FaultCode` that a consumer never selects has no observable effect.

Reading a fault report means reading the owner that selected the member, not this page; the trap owner decides the trap number, argument, and restart behavior.

Read this page as a vocabulary list: the unit declares one enumeration and no functions, so every rule about when a fault is raised, reported, or recovered is owned by another unit.

<!-- PTO-READER-BLOCK: arch-fault-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

The declared identities do not by themselves say that an instruction can produce the corresponding condition, because reachability is decided by each consuming unit.

When another ASL unit uses `Fault_DataAlignment`, read that unit as the owner of the surrounding behavior; this page establishes only that `Fault_DataAlignment` is a distinct `FaultCode` member.

<!-- PTO-READER-BLOCK: arch-fault-related role=related-owners-navigation -->
## Related owners

- [Trap context](trap-context.md) defines the saved trap context state.

- [Execution context](../programming-model/execution-context.md) explains where fault and program-control state fit in the architectural state model.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/fault.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-FAULT","surface":"arch","classification":["data-types","fault"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER"]}
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
    Fault_BundlePostCommit,
    Fault_ServiceRequest
};
```
<!-- GENERATED-ASL-END: unit -->
