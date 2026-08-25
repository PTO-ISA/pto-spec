<!-- GENERATED FROM: asl/arch/programming-model/predicate-registers.asl -->
# Predicate Registers

**Normative ASL source:** `asl/arch/programming-model/predicate-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-predicate-registers-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines the read and write behavior of the predicate-register state and records whether any current instruction encoding consumes P0 through P7.

<!-- PTO-READER-BLOCK: arch-predicate-registers-concepts-state role=concepts-state -->
## Predicate-register view

`ReadPredicateRegister` returns all ones for predicate register index `0`. Other indices read their stored element from `_PredicateRegisters`.

`WritePredicateRegister` stores a value only when the index is not `0`.

<!-- PTO-READER-BLOCK: arch-predicate-registers-rules-interactions role=rules-interactions -->
## Constant predicate and consumers

Together, the read and write rules make P0 a constant all-ones predicate: writing P0 has no state effect, and reading it does not depend on the backing array.

`PredicateRegisterHasInstructionConsumer` returns `FALSE` for every predicate index because the current PTO instruction encoding has no consumer for P0 through P7.

<!-- PTO-READER-BLOCK: arch-predicate-registers-boundaries role=boundaries -->
## Architectural boundaries

The absence of an instruction consumer is an encoding statement in this owner. The consumer query does not change the read and write behavior defined by `ReadPredicateRegister` and `WritePredicateRegister`.

<!-- PTO-READER-BLOCK: arch-predicate-registers-example-usage role=example-usage -->
## Non-normative state example

If a test writes a nonzero pattern to P0 and then reads P0, the read still produces an all-ones `PredicateWord`. The same write to P1 is stored and can be read back from P1.

<!-- PTO-READER-BLOCK: arch-predicate-registers-related-owners role=related-owners-navigation -->
## Related owners

- [Execution context](execution-context.md) owns the predicate backing state used here.
- [Trap context](../state/trap-context.md) saves and restores the predicate array as part of portable trap context.
- [Core PE topology](core-pe-topology.md) declares the predicate-register count and width used by this unit.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/predicate-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS","surface":"arch","classification":["programming-model","predicate-registers"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
readonly func ReadPredicateRegister(index: PredicateIndex) => PredicateWord
begin
    return if index == 0 then Ones{PTO_PREDICATE_WIDTH}
           else _PredicateRegisters[[index]];
end;

func WritePredicateRegister(index: PredicateIndex, value: PredicateWord)
begin
    if index != 0 then
        _PredicateRegisters[[index]] = value;
    end;
end;

pure func PredicateRegisterHasInstructionConsumer(index: PredicateIndex)
        => boolean
begin
    // PTO has no instruction encoding that consumes P0..P7.
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->
