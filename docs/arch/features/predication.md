<!-- GENERATED FROM: asl/arch/features/predication.asl -->
# Predication

**Normative ASL source:** `asl/arch/features/predication.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-PREDICATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-predication-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit is the named architecture concept for predication and depends on the predicate-register programming-model owner.

It provides a stable ownership and navigation point without creating a second predicate-state or execution contract.

<!-- PTO-READER-BLOCK: arch-predication-concepts-state role=concepts-state -->
## Concepts and visible state

- The unit contains only its `PTO-UNIT` identity and dependency on `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS`.
- Predicate register storage, indexing, reset, and reads/writes are defined by that dependency and its reachable state owners.
- Instruction-specific predicate decode and no-op behavior remain with each mnemonic owner.

<!-- PTO-READER-BLOCK: arch-predication-rules-interactions role=rules-interactions -->
## Rules and interactions

This concept introduces no ASL type, function, state variable, or transition.

A reference to predication must be resolved through the predicate-register owner and the consuming instruction's current ASL.

No default predicate sense or instruction coverage can be inferred from this marker-only unit.

<!-- PTO-READER-BLOCK: arch-predication-boundaries role=boundaries -->
## Architectural boundaries

This page cannot add missing predication semantics in explanatory prose; any new rule belongs in an owning ASL/NDF change with validation.

The named concept is portable as an identity, while concrete instruction effects stay local to their mnemonic contracts.

<!-- PTO-READER-BLOCK: arch-predication-example-usage role=example-usage -->
## Non-normative reading example

To decide whether a false predicate suppresses a particular instruction, read that instruction's decode and operation together with the predicate-register owner; this unit alone does not answer the question.

Use this page as the architecture index for the concept, then follow the related owner links for executable details.

<!-- PTO-READER-BLOCK: arch-predication-related-owners role=related-owners-navigation -->
## Related owners

- [Predicate registers](../programming-model/predicate-registers.md)
- [Execution context](../programming-model/execution-context.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/predication.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-PREDICATION","surface":"arch","classification":["features","predication"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
