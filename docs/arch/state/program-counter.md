<!-- GENERATED FROM: asl/arch/state/program-counter.asl -->
# Program Counter

**Normative ASL source:** `asl/arch/state/program-counter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-PROGRAM-COUNTER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-program-counter-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines the read and write helpers for the ordinary program counter, trap program counter, and bundle program counter views.

<!-- PTO-READER-BLOCK: arch-program-counter-concepts-state role=concepts-state -->
## Counter views

`ReadPC` and `ReadTPC` both return `_PC`. `ReadBPC` returns the separate `_BPC` state.

`WritePC` and `WriteTPC` both replace `_PC`, while `WriteBPC` replaces `_BPC`.

<!-- PTO-READER-BLOCK: arch-program-counter-rules-interactions role=rules-interactions -->
## Shared PC storage

PC and TPC are two access names for the same stored `Word`; they are not independent counters in this model. BPC remains independent of that shared storage.

<!-- PTO-READER-BLOCK: arch-program-counter-boundaries role=boundaries -->
## Architectural boundaries

These helpers define storage access only. They do not by themselves define instruction sequencing, alignment checks, trap entry, bundle completion, or recovery eligibility.

<!-- PTO-READER-BLOCK: arch-program-counter-example-usage role=example-usage -->
## Non-normative view example

After `WriteTPC` stores an aligned address, `ReadPC` observes the same value because both use `_PC`. A subsequent `WriteBPC` changes only the value returned by `ReadBPC`.

<!-- PTO-READER-BLOCK: arch-program-counter-related-owners role=related-owners-navigation -->
## Related owners

- [Scalar registers](../programming-model/scalar-registers.md) is the declared dependency.
- [Trap context](trap-context.md) snapshots and restores TPC and BPC.
- [Execution context](../programming-model/execution-context.md) owns the broader program-control state.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/program-counter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-PROGRAM-COUNTER","surface":"arch","classification":["state","program-counter"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
readonly func ReadPC() => Word
begin
    return _PC;
end;

readonly func ReadTPC() => Word
begin
    return _PC;
end;

readonly func ReadBPC() => Word
begin
    return _BPC;
end;

func WritePC(value: Word)
begin
    _PC = value;
end;

func WriteTPC(value: Word)
begin
    _PC = value;
end;

func WriteBPC(value: Word)
begin
    _BPC = value;
end;
```
<!-- GENERATED-ASL-END: unit -->
