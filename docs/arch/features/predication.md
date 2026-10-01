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

The owning file `asl/arch/features/predication.asl` has two lines: the `PTO-UNIT` metadata comment and a comment stating that the unit owns the named concept and that executable state is defined by its dependencies. It declares no type, function, constant, or state variable.

The declared dependency is `PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS`, and that is where the predicate state and its accessors are defined.

<!-- PTO-READER-BLOCK: arch-predication-concepts-state role=concepts-state -->
## Executable state in the dependency

- `ReadPredicateRegister(index: PredicateIndex) => PredicateWord` returns `Ones{PTO_PREDICATE_WIDTH}` when `index == 0` and `_PredicateRegisters[[index]]` otherwise.
- `WritePredicateRegister(index: PredicateIndex, value: PredicateWord)` performs `_PredicateRegisters[[index]] = value` only when `index != 0`.
- `PredicateRegisterHasInstructionConsumer(index: PredicateIndex) => boolean` returns `FALSE` for every index, with the comment that PTO has no instruction encoding that consumes `P0..P7`.
- `PredicateIndex` is an integer in `0..PTO_PREDICATE_REGISTER_COUNT-1` and `PredicateWord` is `bits(PTO_PREDICATE_WIDTH)`, with `PTO_PREDICATE_REGISTER_COUNT = 8` and `PTO_PREDICATE_WIDTH = 32`.
- The backing store is `var _PredicateRegisters : PredicateSnapshot`, an array of `PTO_PREDICATE_REGISTER_COUNT` `PredicateWord` values, and it is a member of state `PTO-STATE-ARCH-PROGRAM-CONTROL`.

Design point: index `0` is a constant source rather than a register. Reads of `P0` return `Ones{32}` and the write guard drops every write to `P0`, so `ReadPredicateRegister(0)` returns the same value before and after any `WritePredicateRegister(0, value)`. All-ones is therefore always readable without storage, and a write to `0` is a no-op rather than an error.

Design point: storage and consumption are separate predicates. `PredicateRegisterHasInstructionConsumer` returns `FALSE` for all `8` indices, so an instruction's predicate effect cannot be traced to this dependency; the answer has to come from the consuming instruction's own decode and operation.

<!-- PTO-READER-BLOCK: arch-predication-rules-interactions role=rules-interactions -->
## Rules and interactions

A write replaces the whole `32`-bit `PredicateWord`. There is no partial write, no lane mask, and no per-element definedness flag in the dependency.

Neither function calls `SetFault`, so no fault is raised for any `PredicateIndex`, including `0`. Reads and writes leave `_PC`, `_BPC`, the bundle flags, and the fault state unchanged.

`ResetProfileState` in `PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING` clears the file by assigning `Zeros{PTO_PREDICATE_WIDTH}` to indices `0` through `PTO_PREDICATE_REGISTER_COUNT - 1`. Immediately after a reset every read of `P1` through `P7` returns `Zeros{32}`, while every read of `P0` still returns `Ones{32}`.

No unit under `asl/` calls the three functions; the calls in this repository are in tests under `tests/asl/arch/programming-model/predicate-registers/`.

<!-- PTO-READER-BLOCK: arch-predication-boundaries role=boundaries -->
## Architectural boundaries

This page cannot add missing predication semantics. The owning file contains no definition to refine, so a new rule about predicate sense, coverage, or suppression must be added to the dependency or to an instruction owner.

The marker also does not define a default predicate sense, a list of instructions that read predicates, or a fault for reading a register that was never written. The dependency defines reads, writes, and the consumer question, and nothing else.

Design point: the constant read of `P0` and the dropped write to `P0` are produced by the `index == 0` and `index != 0` tests in the two functions, not by reserving array element `0`. Element `0` of `_PredicateRegisters` still exists and is still reset, but no read can observe it through `ReadPredicateRegister`.

<!-- PTO-READER-BLOCK: arch-predication-example-usage role=example-usage -->
## Non-normative reading example

A reader tracing a write can follow the value directly: `WritePredicateRegister(1, value)` assigns `_PredicateRegisters[[1]] = value`, and a later `ReadPredicateRegister(1)` returns that same `PredicateWord`.

The same trace against `0` diverges: `WritePredicateRegister(0, value)` leaves the array untouched, and `ReadPredicateRegister(0)` returns `Ones{32}` regardless of `value`.

To decide whether a false predicate suppresses an instruction, read that instruction's decode and operation; `PredicateRegisterHasInstructionConsumer(0)` and `PredicateRegisterHasInstructionConsumer(7)` both return `FALSE`, so the dependency reports no instruction consumer at either end of the index range.

<!-- PTO-READER-BLOCK: arch-predication-related-owners role=related-owners-navigation -->
## Related owners

- [Predicate registers](../programming-model/predicate-registers.md) defines reads, writes, and the consumer question.
- [Execution context](../programming-model/execution-context.md) declares `_PredicateRegisters` as part of `PTO-STATE-ARCH-PROGRAM-CONTROL`.
- [Integer types](../data-types/integer.md) defines `PredicateIndex` and `PredicateWord`.
- [Trap context](../state/trap-context.md) saves and restores the predicate snapshot with the trap context.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/predication.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-PREDICATION","surface":"arch","classification":["features","predication"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->
