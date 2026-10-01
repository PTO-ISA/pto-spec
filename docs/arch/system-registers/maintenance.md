<!-- GENERATED FROM: asl/arch/system-registers/maintenance.asl -->
# Maintenance

**Normative ASL source:** `asl/arch/system-registers/maintenance.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-maintenance-purpose-scope role=purpose-scope -->
## Purpose and scope

This page has one thing to describe, and the description is short: the unit carries only its `PTO-UNIT` metadata line. There is no ASL declaration, constant, type, variable, function, or state transition in the file.

The unit exists so that maintenance behavior has a stable identity in the dependency graph. Reading it tells you what it depends on and nothing about what a maintenance operation does.

<!-- PTO-READER-BLOCK: arch-system-maintenance-concepts-state role=concepts-state -->
## Owner contents

The declared identity is `PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE`, classified under `system-registers` and `maintenance`.

The declared dependency is `PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION`, which is the unit that owns fault precision for memory behavior.

No member state is listed, because the owner holds no state of its own. The maintenance state record that does exist, `PTO-STATE-ARCH-MAINTENANCE`, is owned by the execution-context unit rather than by this one.

<!-- PTO-READER-BLOCK: arch-system-maintenance-rules-interactions role=rules-interactions -->
## Where the behavior actually lives

The state that maintenance operations do keep, the last maintenance operation, the last maintenance operand, and the data-cache, instruction-cache, bundle-cache, and translation epochs, is owned by `PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT` and appears in its state record.

The operation selector and its list of maintenance operations are declared with the other system-register data types, and each maintenance instruction has its own page under the scalar surface.

This page adds no rule on top of those owners.

<!-- PTO-READER-BLOCK: arch-system-maintenance-boundaries role=boundaries -->
## Architectural boundaries

Because the unit declares no register, this page assigns no address, no reset value, no access permission, no cache behavior, no completion behavior, and no fault side effect of its own. Those rules do exist, but they belong to the maintenance operations themselves: the translation operations are assigned to the root ring, the cache operations advance a data, instruction, or bundle cache epoch, and a rejected access or operand raises `Fault_IllegalInstruction` or `Fault_DataPage`.

The dependency edge means that when a maintenance question reaches this unit, the fault-precision owner is the next place to look; it does not mean this unit restates or extends the fault-precision rules.

Design point: a unit can hold a place in the graph without holding behavior. Keeping the placeholder explicit means the absence of a maintenance register is visible to a reader instead of being hidden behind a page that looks like an owner.

<!-- PTO-READER-BLOCK: arch-system-maintenance-example-usage role=example-usage -->
## Non-normative reading example

A reader arriving from a maintenance instruction page should take the operation semantics from that instruction page, then follow the dependency edge to the fault-precision owner if the question is about when a fault is reported.

A reader arriving from the dependency graph should treat this unit as the name of a boundary, not as evidence that a maintenance register with unstated behavior exists.

<!-- PTO-READER-BLOCK: arch-system-maintenance-related-owners role=related-owners-navigation -->
## Related owners

- [Fault precision](../memory-model/fault-precision.md) is the declared dependency.
- [Execution context](../programming-model/execution-context.md) owns the maintenance operation and epoch state.
- [System-register data types](../data-types/system-registers.md) declares the maintenance operation selector.
- [System-register addressing](addressing.md) owns the base system-register record and the reference reset.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/maintenance.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE","surface":"arch","classification":["system-registers","maintenance"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
```
<!-- GENERATED-ASL-END: unit -->
