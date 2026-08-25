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

This unit provides the stable system-registers identity for maintenance behavior in the architecture dependency graph.

<!-- PTO-READER-BLOCK: arch-system-maintenance-concepts-state role=concepts-state -->
## Owner contents

The owner contains only its `PTO-UNIT` declaration. It declares no maintenance register, field, helper, or state transition locally.

<!-- PTO-READER-BLOCK: arch-system-maintenance-rules-interactions role=rules-interactions -->
## Dependency relationship

`PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE` depends on `PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION`. Any executable maintenance or fault-precision behavior must come from a reachable current owner.

<!-- PTO-READER-BLOCK: arch-system-maintenance-boundaries role=boundaries -->
## Architectural boundaries

This page does not assign addresses, reset values, permissions, cache behavior, completion behavior, or fault side effects to a maintenance register. Those would be new semantics absent from this owner.

<!-- PTO-READER-BLOCK: arch-system-maintenance-example-usage role=example-usage -->
## Non-normative reading example

When a maintenance-related fault question reaches this page, continue to the fault-precision dependency and then to the exact instruction or state-transition owner. Do not treat the existence of this navigation unit as evidence for an unstated register behavior.

<!-- PTO-READER-BLOCK: arch-system-maintenance-related-owners role=related-owners-navigation -->
## Related owners

- [Fault precision](../memory-model/fault-precision.md) is the direct dependency.
- [System-register addressing](addressing.md) owns the base system-register state record.
- [Architecture overview](../overview/architecture.md) explains why generated navigation cannot create semantics.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/maintenance.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE","surface":"arch","classification":["system-registers","maintenance"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
```
<!-- GENERATED-ASL-END: unit -->
