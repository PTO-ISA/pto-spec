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

`FaultCode` is the PTO ASL enumeration for `Fault_None` and fifteen named non-`None` fault identities. This unit defines only those identities; it does not define when they are selected or what transition follows.

<!-- PTO-READER-BLOCK: arch-fault-concepts role=concepts-state -->
## Fault groups

`Fault_None` represents no active fault. Execution checking, illegal instruction, instruction address/page, data alignment/page, debug, assertion, Tile legality/allocation, bundle control/post-commit, and service request each have distinct enumeration members.

The separation lets later ASL owners select a cause without encoding trap numbers or recovery behavior into this type definition.

<!-- PTO-READER-BLOCK: arch-fault-rules role=rules-interactions -->
## How the code is used

A `FaultCode` value is exactly one member of this enumeration. The declaration does not assign trap numbers, priorities, payloads, or recovery behavior.

The AVS linked to this unit provides cross-owner execution evidence; it is not part of the enumeration definition on this page.

<!-- PTO-READER-BLOCK: arch-fault-boundaries role=boundaries -->
## Boundaries

`Fault_BundleControl` and `Fault_BundlePostCommit` are distinct enumeration members. `Fault_TileLegality` and `Fault_TileAllocation` are also distinct members.

Questions about which instruction selects a member, or how a trap or profile owner interprets it, are outside this type declaration.

<!-- PTO-READER-BLOCK: arch-fault-example role=example-usage -->
## Non-normative reading example

This example is a reading aid, not a new fault rule.

When another ASL unit uses `Fault_DataAlignment`, read that unit as the owner of the surrounding behavior; this page establishes only that `Fault_DataAlignment` is a distinct `FaultCode` member.

<!-- PTO-READER-BLOCK: arch-fault-related role=related-owners-navigation -->
## Related owners

- [Trap context](trap-context.md) defines saved trap context state.
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
